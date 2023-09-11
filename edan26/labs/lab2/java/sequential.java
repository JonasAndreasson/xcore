import java.util.Scanner;
import java.util.Iterator;
import java.util.ListIterator;
import java.util.LinkedList;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.ReentrantLock;

import java.io.*;

class Graph {

	int	s;
	int	t;
	int	n;
	int	m;
	int threads;
	AtomicInteger buffer;
	Node	excess;		// list of nodes with excess preflow
	Node	node[];
	Edge	edge[];

	Graph(Node node[], Edge edge[], int threads)
	{
		buffer = new AtomicInteger(0);
		this.threads = threads;
		this.node	= node;
		this.n		= node.length;
		this.edge	= edge;
		this.m		= edge.length;
	}

	synchronized void enter_excess(Node u)
	{
		if (u != node[s] && u != node[t]) {
			u.next = excess;
			excess = u;
		}
	}

	synchronized Node leave_excess(){
		Node t = excess;
		if(t != null) excess = t.next;
		return t;
	}

	Node other(Edge a, Node u)
	{
		if (a.u == u)	
			return a.v;
		else
			return a.u;
	}

	void relabel(Node u)
	{
		u.mutex.lock();
		u.h++;
		enter_excess(u);
		u.mutex.unlock();
	}

	void push(Node u, Node v, Edge a)
	{
		int d;
		if (u == a.u) {
			d = Math.min(u.e, a.c - a.f);
			a.f += d;
		} else {
			d = Math.min(u.e, a.c + a.f);
			a.f -= d;
		}
		u.e -= d;
		v.e += d;
		if (u.e > 0){
			enter_excess(u);
		}
		if (v.e == d){
			enter_excess(v);
		}
	}

	int preflow(int s, int t)
	{
		ListIterator<Edge>	iter;
		Edge			a;
		
		this.s = s;
		this.t = t;
		node[s].h = n;

		iter = node[s].adj.listIterator();
		while (iter.hasNext()) {
			a = iter.next();

			node[s].e += a.c;

			push(node[s], other(a, node[s]), a);
		}

		PreflowPush[] threadArray = new PreflowPush[threads];
		System.out.println(threads + " thread(s)");

		for (int i = 0; i < threads; i++){
			threadArray[i] = new PreflowPush(this);
		}

		for (int i = 0; i < threads; i++){
			threadArray[i].start();
		}

		for (int i = 0; i < threads; i++) {
			try {
				threadArray[i].join();
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		return node[t].e;
	}
}

class PreflowPush extends Thread{
	Graph g;

	PreflowPush(Graph g){
		this.g = g;
	}

	public void run()
	{
		ListIterator<Edge>	iter;
		int			b;
		Edge			a;
		Node			u;
		Node			v;
    	boolean amWorking = true;
    	g.buffer.getAndIncrement();

		
    while(g.buffer.get() != 0){

		while ((u = g.leave_excess()) != null) {
		  	
			if(!amWorking){
			amWorking = true;
			g.buffer.getAndIncrement();
			}
				
				v = null;
				a = null;

				iter = u.adj.listIterator();
				while (iter.hasNext()) {
					a = iter.next();

					if (u == a.u){ //DIRECTION
						v = a.v;
						b = 1;
					}else {
						v = a.u;
						b = -1;
					}

					if(u.i < v.i){ //LOCK ORDER
						u.mutex.lock();
						v.mutex.lock();
					} else {
						v.mutex.lock();
						u.mutex.lock();
					}

					if (u.h > v.h && b*a.f < a.c){
						break;
					}
					else {
						u.mutex.unlock();
						v.mutex.unlock();
						v = null;
					}
				}

				if (v != null){
					g.push(u, v, a);
					u.mutex.unlock();
					v.mutex.unlock();
				}
				else {
					System.out.println(u.h);
					g.relabel(u);
				}
		}
      
      if(amWorking){
		g.buffer.getAndDecrement();
      	amWorking = false;
	  }

    }
		System.out.println("job done ");
	}

}
class Node {
	int	h;
	int	e;
	int	i;
	Node	next;
	LinkedList<Edge>	adj;
	ReentrantLock mutex;

	Node(int i)
	{
		this.i = i;
		adj = new LinkedList<Edge>();
		mutex = new ReentrantLock();
	}
}

class Edge {
	Node	u;
	Node	v;
	int	f;
	int	c;

	Edge(Node u, Node v, int c)
	{
		this.u = u;
		this.v = v;
		this.c = c;

	}
}

class Preflow {
	public static void main(String args[])
	{
		double	begin = System.currentTimeMillis();
		Scanner s = new Scanner(System.in);
		int	n;
		int	m;
		int	i;
		int	u;
		int	v;
		int	c;
		int	f;
		Graph	g;

		n = s.nextInt();
		m = s.nextInt();
		s.nextInt();
		s.nextInt();
		Node[] node = new Node[n];
		Edge[] edge = new Edge[m];
		int threads = 16;

		for (i = 0; i < n; i += 1)
			node[i] = new Node(i);

		for (i = 0; i < m; i += 1) {
			u = s.nextInt();
			v = s.nextInt();
			c = s.nextInt(); 
			edge[i] = new Edge(node[u], node[v], c);
			node[u].adj.addLast(edge[i]);
			node[v].adj.addLast(edge[i]);
		}

		g = new Graph(node, edge, threads);
		f = g.preflow(0, n-1);
		double	end = System.currentTimeMillis();
		System.out.println("t = " + (end - begin) / 1000.0 + " s");
		System.out.println("f = " + f);
	}
}
