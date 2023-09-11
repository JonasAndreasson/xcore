#include <pthread.h>
typedef struct graph_t	graph_t;
typedef struct node_t	node_t;
typedef struct edge_t	edge_t;
typedef struct list_t	list_t;

struct list_t {
	edge_t*		edge;
	list_t*		next;
};

struct node_t {
	int h;
	int	e;
	int i;
    list_t*	edge;	/* adjacency list.		*/
	node_t*	next;	/* with excess preflow.		*/
    pthread_mutex_t lock;
};

struct edge_t {
	node_t*		u;	/* one of the two nodes.	*/
	node_t*		v;	/* the other. 			*/
	int		f;	/* flow > 0 if from u to v.	*/
	int		c;	/* capacity.			*/
};

struct graph_t {
	int		n;	/* nodes.			*/
	int		m;	/* edges.			*/
	node_t*		v;	/* array of n nodes.		*/
	edge_t*		e;	/* array of m edges.		*/
	node_t*		s;	/* source.			*/
	node_t*		t;	/* sink.			*/
	node_t*		excess;	/* nodes with e > 0 except s,t.	*/
};

int main(){
    int n, m,i,u,v,c,f;
    struct Graph g;

    return 0;
}