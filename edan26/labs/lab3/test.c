void* preflow_push(void* arg){
	graph_t* g = (graph_t*) arg;
	int b;
	int done_process = 0;
	node_t* u;
	node_t* v;
	list_t* p;
	edge_t* e;
	bool am_working = true;
	atomic_fetch_add(g->buffer, 1);

	while(atomic_load(g->buffer)!=0){

	
	while ((u = leave_excess(g)) != NULL) {

		/* u is any node with excess preflow. */
		if(!am_working){
			am_working = true;
			atomic_fetch_add(g->buffer, 1);
		}


		pr("selected u = %d with ", id(g, u));
		pr("h = %d and e = %d\n", u->h, u->e);

		v = NULL;
		p = u->edge;
		//PUSH PHASE
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
				break;
			}else{
				v = NULL;
			}
		}

		if (v != NULL){
			push(g, u, v, e);
		}
		//RELABEL AND UPDATE VALUE PHASE
		else{
			relabel(g, u);
		}
		done_process+=1;
	}
	if(am_working){
		atomic_fetch_sub(g->buffer, 1);
      	am_working = false;
	  }
	}
	printf("%d Completed tasks\n", done_process);
}