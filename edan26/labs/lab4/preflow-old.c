#include <assert.h>
#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdatomic.h>
#include <string.h>
#include <pthread.h>
#include <stdbool.h>
//#include "timebase.h"
#include "pthread_barrier.h"
#define PRINT		0	/* enable/disable prints. */
#define THREAD_CAP 16
#if PRINT
#define pr(...)		do { fprintf(stderr, __VA_ARGS__); } while (0)
#else
#define pr(...)		/* no effect at all */
#endif

#define MIN(a,b)	(((a)<=(b))?(a):(b))
typedef struct graph_t	graph_t;
typedef struct node_t	node_t;
typedef struct edge_t	edge_t;
typedef struct list_t	list_t;
typedef struct flow_t	flow_t;
typedef struct index_t	index_t;

struct list_t {
	edge_t*		edge;
	list_t*		next;
};

struct node_t {
	int 	i;
	int		h;	/* height.			*/
	int		e;	/* excess flow.			*/
	list_t*		edge;	/* adjacency list.		*/
	node_t*		next;	/* with excess preflow.		*/
	atomic_int inc;
};

struct edge_t {
	node_t*		u;	/* one of the two nodes.	*/
	node_t*		v;	/* the other. 			*/
	int		f;	/* flow > 0 if from u to v.	*/
	int		c;	/* capacity.			*/
};
struct flow_t{
	node_t* u;
	node_t* v;
};

struct graph_t {
	int		n;	/* nodes.			*/
	int		m;	/* edges.			*/
	node_t*		v;	/* array of n nodes.		*/
	edge_t*		e;	/* array of m edges.		*/
	node_t*		s;	/* source.			*/
	node_t*		t;	/* sink.			*/
	//node_t*		excess;	/* nodes with e > 0 except s,t.	*/
	pthread_barrier_t* barrier;
	int buffer;
	int number_of_threads;
	flow_t	jobs[THREAD_CAP];
	node_t* excess[THREAD_CAP];
};
struct index_t{
	graph_t* g;
	int index;
};






static char* progname;


static int id(graph_t* g, node_t* v)
{

	return v - g->v;
}

void error(const char* fmt, ...)
{

	va_list		ap;
	char		buf[BUFSIZ];

	va_start(ap, fmt);
	vsprintf(buf, fmt, ap);

	if (progname != NULL)
		fprintf(stderr, "%s: ", progname);

	fprintf(stderr, "error: %s\n", buf);
	exit(1);
}

static int next_int()
{
        int     x;
        int     c;

	x = 0;
        while (isdigit(c = getchar()))
                x = 10 * x + c - '0';

        return x;
}

static void* xmalloc(size_t s)
{
	void*		p;
	p = malloc(s);

	if (p == NULL)
		error("out of memory: malloc(%zu) failed", s);

	return p;
}

static void* xcalloc(size_t n, size_t s)
{
	void*		p;

	p = xmalloc(n * s);

	/* memset sets everything (in this case) to 0. */
	memset(p, 0, n * s);

	return p;
}

static void add_edge(node_t* u, edge_t* e)
{
	list_t*		p;

	/* allocate memory for a list link and put it first
	 * in the adjacency list of u.
	 *
	 */

	p = xmalloc(sizeof(list_t));
	p->edge = e;
	p->next = u->edge;
	u->edge = p;
}

static void connect(node_t* u, node_t* v, int c, edge_t* e)
{
	/* connect two nodes by putting a shared (same object)
	 * in their adjacency lists.
	 *
	 */

	e->u = u;
	e->v = v;
	e->c = c;

	add_edge(u, e);
	add_edge(v, e);
}

static graph_t* new_graph(FILE* in, int n, int m)
{
	graph_t*	g;
	node_t*		u;
	node_t*		v;
	int		i;
	int		a;
	int		b;
	int		c;
	
	g = xmalloc(sizeof(graph_t));

	g->n = n;
	g->m = m;
	g->barrier = xmalloc(sizeof(pthread_barrier_t));
	g->v = xcalloc(n, sizeof(node_t));
	g->e = xcalloc(m, sizeof(edge_t));
	g->s = &g->v[0];
	g->t = &g->v[n-1];
	for (i = 0; i < THREAD_CAP; i+=1){
		g->excess[i] = NULL;
	}
	g->buffer = 0;
	

	for (i = 0; i < m; i += 1) {
		a = next_int();
		b = next_int();
		c = next_int();
		u = &g->v[a];
		u->i = a;
		v = &g->v[b];
		v->i = b;
		connect(u, v, c, g->e+i);
	}

	return g;
}

static void enter_excess(graph_t* g, node_t* v)
{
	/* put v at the front of the list of nodes
	 * that have excess preflow > 0.
	 *
	 * note that for the algorithm, this is just
	 * a set of nodes which has no order but putting it
	 * it first is simplest.
	 *
	 */
	int hash = v->i%(g->number_of_threads-1);
	if (v != g->t && v != g->s) {
		v->next = g->excess[hash];
		g->excess[hash] = v;
	}
}

static node_t* leave_excess(graph_t* g, int index)
{
	node_t*		v;

	/* take any node from the set of nodes with excess preflow
	 * and for simplicity we always take the first.
	 *
	 */
	v = g->excess[index];
	if (v != NULL)
		g->excess[index] = v->next;
	return v;
}

static void push(graph_t* g, node_t* u, node_t* v, edge_t* e)
{
	int		d;	/* remaining capacity of the edge. */

	pr("push from %d to %d: ", id(g, u), id(g, v));
	pr("f = %d, c = %d, so ", e->f, e->c);
	
	if (u == e->u) {
		d = MIN(u->e, e->c - e->f);
		e->f += d;
	} else {
		d = MIN(u->e, e->c + e->f);
		e->f -= d;
	}

	pr("pushing %d\n", d);

	u->e -= d;
	v->e += d;

	/* the following are always true. */

	assert(d >= 0);
	assert(u->e >= 0);
	assert(abs(e->f) <= e->c);
	if (u->e > 0) {

		/* still some remaining so let u push more. */
		enter_excess(g, u);
	}
	if (v->e == d) {

		/* since v has d excess now it had zero before and
		 * can now push.
		 *
		 */
		enter_excess(g, v);
	}
	
}
static void atomic_push(graph_t* g, node_t* u, node_t* v)
{
	int		d;	/* remaining capacity of the edge. */
	if (u->inc != 0){
		u->e += u->inc;
		u->inc = 0;
	}
	if (v->inc == 0){
		if (u->e > 0) {
		enter_excess(g, u);
		}
		return;
	}
	v->e += v->inc;
	/* the following are always true. */
	assert(u->e >= 0);
	if (u->e > 0) {

		/* still some remaining so let u push more. */
		enter_excess(g, u);
	}
	if (v->e == v->inc) {

		/* since v has d excess now it had zero before and
		 * can now push.
		 *
		 */
		enter_excess(g, v);
	}
	v->inc = 0;
}





static void relabel(graph_t* g, node_t* u)
{

	u->h += 1;
	pr("relabel %d now h = %d\n", id(g, u), u->h);
	enter_excess(g, u);
}

static node_t* other(node_t* u, edge_t* e)
{
	if (u == e->u)
		return e->v;
	else
		return e->u;
}

void* preflow_push(void* arg){
	index_t* capsule = (index_t*) arg;
	graph_t* g = capsule->g;
	int index = capsule->index;
	int b;
	int done_process = 0;
	node_t* u;
	node_t* v;
	list_t* p;
	edge_t* e;
	bool am_working = true;

	while(1){
		while ((u = leave_excess(g, index)) != NULL) {

			/* u is any node with excess preflow. */

			pr("selected u = %d with ", id(g, u));
			pr("h = %d and e = %d\n", u->h, u->e);
			v = NULL;
			p = u->edge;
			while (p != NULL) {
				e = p->edge;
				p = p->next;

				if (u == e->u) {
					v = e->v;
					b = 1;
				} else {
					v = e->u;
					b = -1;
					}

				if (u->h > v->h && b * e->f < e->c){
					int d;
					if (u == e->u) {
						d = MIN(u->e, e->c - e->f);
						e->f += d;
					} else {
						d = MIN(u->e, e->c + e->f);
						e->f -= d;
					}
					u->inc -= d;
					v->inc += d;
					break;
				}else{
					v = NULL;
				}
			}
			bool temp = false;
			flow_t f = {.u=u, .v=v}; //contains inc
			g->jobs[index]=f;
			pthread_barrier_wait(g->barrier); //Wait for Phase 1 To complete
			done_process+=1;
			pthread_barrier_wait(g->barrier); //Wait for Phase 2 To complete
			if(g->buffer)break;
		}
		if(g->buffer)break;
		if (u==NULL){ //basically while else
			pthread_barrier_wait(g->barrier); //Wait for Phase 1 To complete
			pthread_barrier_wait(g->barrier); //Wait for Phase 2 To complete
			if(g->buffer)break;
		}
	}
	pr("%d Completed %d tasks\n", index, done_process);
}

void* control_flow(void* arg){
	graph_t* g = (graph_t*) arg;
	bool am_working = true;
	int k;
	while(1){
		k = 0;
		pthread_barrier_wait(g->barrier);//Wait for Phase 1 To complete
		for (int i = 0; i < THREAD_CAP; i+=1){
			flow_t f = g->jobs[i];
			if (f.u==NULL){	
				k+=1;
				continue;
			}
			
			if (f.v != NULL){
				atomic_push(g,f.u, f.v);
			} else {
				relabel(g,f.u);
			}
			g->jobs[i].u=NULL;
		}
		if (k==THREAD_CAP){
			g->buffer=1;
		}
		pthread_barrier_wait(g->barrier);//Wait for Phase 2 To complete
		if(g->buffer)break;
	}
}
	
int preflow(graph_t* g)
{
	node_t*		s;
	node_t*		u;
	node_t*		v;
	edge_t*		e;
	list_t*		p;
	int		b;

	s = g->s;
	s->h = g->n;

	p = s->edge;

	/* start by pushing as much as possible (limited by
	 * the edge capacity) from the source to its neighbors.
	 *
	 */

	while (p != NULL) {
		e = p->edge;
		p = p->next;

		s->e += e->c;
		push(g, s, other(s, e), e);
	}
	
	
	/* then loop until only s and/or t have excess preflow. */
	
	if (g->n>2) g->number_of_threads = 1+(g->n-3)/10;
	else g->number_of_threads = 1;
	if (g->number_of_threads>THREAD_CAP) g->number_of_threads = THREAD_CAP;
	if (g->number_of_threads == 1) g->number_of_threads++;
	
	//g->number_of_threads = 3;
	pthread_barrier_init(g->barrier, NULL, g->number_of_threads);
	for (int i = 0; i < THREAD_CAP; i+=1){
		flow_t f = {.u=NULL, .v=NULL};
		g->jobs[i] = f;
	}

	
	pthread_t thread_id[g->number_of_threads];
	index_t capsulate_g[g->number_of_threads-1];
	for (int i = 0; i < g->number_of_threads-1; i+=1){
		const int j = 0+i;
		index_t item = {.g=g, .index=j};
		capsulate_g[i] = item;
    	pthread_create(&(thread_id[i]), NULL, preflow_push, &capsulate_g[i]);
	}
	pthread_create(&(thread_id[g->number_of_threads-1]), NULL, control_flow, g);
	

	for (int i = 0; i < g->number_of_threads; i+=1){
		void *ret;
    	pthread_join(thread_id[i], ret);
		pr("Thread %d is done!\n", i);
	}
	return g->t->e;
}

static void free_graph(graph_t* g)
{
	int		i;
	list_t*		p;
	list_t*		q;

	for (i = 0; i < g->n; i += 1) {
		p = g->v[i].edge;
		while (p != NULL) {
			q = p->next;
			free(p);
			p = q;
		}
	}
	free(g->v);
	free(g->e);
	pthread_barrier_destroy(g->barrier);
	free(g->barrier);
	free(g);
}

int main(int argc, char* argv[])
{
	FILE*		in;	/* input file set to stdin	*/
	graph_t*	g;	/* undirected graph. 		*/
	int		f;	/* output from preflow.		*/
	int		n;	/* number of nodes.		*/
	int		m;	/* number of edges.		*/

	progname = argv[0];	/* name is a string in argv[0]. */
	//init_timebase();
	in = stdin;		/* same as System.in in Java.	*/

	n = next_int();
	m = next_int();

	/* skip C and P from the 6railwayplanning lab in EDAF05 */
	next_int();
	next_int();

	g = new_graph(in, n, m);

	fclose(in);

	//double	begin = timebase_sec();
	f = preflow(g);
	//double end = timebase_sec();
	//printf("t = %lf s\n", end-begin);
	printf("f = %d\n", f);

	free_graph(g);

	return 0;
}
