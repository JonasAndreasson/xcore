#![allow(warnings)]

#[macro_use] extern crate text_io;


use std::sync::{Mutex,Arc};
use std::collections::LinkedList;
use std::cmp;
use std::thread;
use std::collections::VecDeque;

struct Node {
	i:	usize,			/* index of itself for debugging.	*/
	e:	i32,			/* excess preflow.			*/
	h:	usize,			/* height.				*/
}

struct Edge {
        u:      usize,  
        v:      usize,
        f:      i32,
        c:      i32,
}

impl Node {
	fn new(ii:usize) -> Node {
		Node { i: ii, e: 0, h: 0 }
	}
	fn push(&mut self, d:i32) {
		self.e += d;
	}

}

impl Edge {
        fn new(uu:usize, vv:usize,cc:i32) -> Edge {
                Edge { u: uu, v: vv, f: 0, c: cc }      
        }
		fn other(&self, uu:usize) -> usize {
			if uu == self.u { self.v } 
			else { self.u }
		}
		fn add_flow(&mut self, sender: usize, flow:i32) {
			if sender == self.u {self.f+=flow;}
			else {self.f -= flow;}
		}
		fn is_u(&self, uu:usize) -> bool {
			if uu == self.u { true }
			else { false }
		}
		
}


fn main() {

	let n: usize = read!();		/* n nodes.						*/
	let m: usize = read!();		/* m edges.						*/
	let _c: usize = read!();	/* underscore avoids warning about an unused variable.	*/
	let _p: usize = read!();	/* c and p are in the input from 6railwayplanning.	*/
	let mut node = vec![];
	let mut edge = vec![];
	let mut threads = vec![];
	let mut adj: Vec<LinkedList<usize>> =Vec::with_capacity(n);
	let mut excess: VecDeque<usize> = VecDeque::new();
	let debug = false;
	let num_threads = 8;
	let s = 0;
	let t = n-1;

	println!("n = {}", n);
	println!("m = {}", m);

	for i in 0..n {
		let u:Node = Node::new(i);
		node.push(Arc::new(Mutex::new(u))); 
		adj.push(LinkedList::new());
	}

	for i in 0..m {
		let u: usize = read!();
		let v: usize = read!();
		let c: i32 = read!();
		let e:Edge = Edge::new(u,v,c);
		adj[u].push_back(i);
		adj[v].push_back(i);
		edge.push(Arc::new(Mutex::new(e))); 
	}

	if debug {
		for i in 0..n {
			print!("adj[{}] = ", i);
			let iter = adj[i].iter();

			for e in iter {
				print!("e = {}, ", e);
			}
			println!("");
		}
	}

	println!("initial pushes");
	node[s].lock().unwrap().h = n;
	let iter = adj[s].iter();
	for item in iter{
		let mut edge_to_push = edge[*item].lock().unwrap();
		let target = edge_to_push.other(s);
		let d = edge_to_push.c;
		node[s].lock().unwrap().push(-d);
		node[target].lock().unwrap().push(d);
		edge_to_push.add_flow(s,d);
		excess.insert(0,target);
	}

	let ex = Arc::new(Mutex::new(excess));

	for _ in 0 .. num_threads {
		let mut completed_tasks = 0;
		let excess = ex.clone();
		let a = adj.clone();
		let e = edge.clone();
		let n = node.clone();
		let h = thread::spawn( move || {
			loop {
				let mut excess_lock = excess.lock().unwrap();
				if excess_lock.is_empty() {
					break;
				}
				let u = excess_lock.pop_front().unwrap(); //index of a node with excess
				drop(excess_lock);
				if u == s || u == t {continue;} 
				let iter = a[u].iter();
				let mut v = u;
				for item in iter{
					let mut edge_to_push = e[*item].lock().unwrap();
					v = edge_to_push.other(u);
					let mut b = 0;
					if edge_to_push.is_u(u) {
						b = 1;
					}
					else {
						b = -1
					} //lås här
					let mut v_lock;
					let mut u_lock;
					if u<v {
						u_lock = n[u].lock().unwrap();
						v_lock = n[v].lock().unwrap();	
					} else {
						v_lock = n[v].lock().unwrap();
						u_lock = n[u].lock().unwrap();
					}
					if v_lock.h < u_lock.h && b * edge_to_push.f < edge_to_push.c {
						let mut d = 0;
						if edge_to_push.is_u(u) {
							d = cmp::min(u_lock.e, edge_to_push.c - edge_to_push.f);
							edge_to_push.f += d;
						} else {
							d = cmp::min(u_lock.e, edge_to_push.c + edge_to_push.f);
							edge_to_push.f -= d;
						}
						{
						u_lock.e -= d;
						if u_lock.e > 0 {
							excess.lock().unwrap().insert(0,u);
						}
						}
						{
						v_lock.e += d;
						if v_lock.e == d {
							excess.lock().unwrap().insert(0,v);
						}
						}
						break;
					} else {
						v = u;
					}
					drop(u_lock);
					drop(v_lock);
				}
				if u != v {

				} else {
					n[u].lock().unwrap().h+=1;
					excess.lock().unwrap().insert(0,u);
				}
				completed_tasks+=1;
	} 
	println!("Completed {} tasks", completed_tasks);
	});
	threads.push(h);
}

	for h in threads {
		h.join().unwrap();
	}

	println!("f = {}", node[t].lock().unwrap().e);

}
