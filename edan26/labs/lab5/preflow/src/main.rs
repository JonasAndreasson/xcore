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
	let mut adj: Vec<LinkedList<usize>> =Vec::with_capacity(n);
	let mut excess: VecDeque<usize> = VecDeque::new();
	let debug = false;

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
	// but nothing is done here yet...

	while !excess.is_empty() {
		let mut c = 0;
		let u = excess.pop_front().unwrap(); //index of a node with excess
		println!("{}",excess.len());
		if u == s || u == t {continue;}
		let iter = adj[u].iter();
		let mut v = u;
		for item in iter{
			let mut edge_to_push = edge[*item].lock().unwrap();
			v = edge_to_push.other(u);
			let mut b = 0;
			if edge_to_push.is_u(u) {
				b = 1;
			}
			else {
				b = -1
			}
			if node[v].lock().unwrap().h < node[u].lock().unwrap().h && b * edge_to_push.f < edge_to_push.c {
				let mut d = 0;
				if edge_to_push.is_u(u) {
					d = cmp::min(node[u].lock().unwrap().e, edge_to_push.c - edge_to_push.f);
					edge_to_push.f += d;
				} else {
					d = cmp::min(node[u].lock().unwrap().e, edge_to_push.c + edge_to_push.f);
					edge_to_push.f -= d;
				}
				node[u].lock().unwrap().e -= d;
				node[v].lock().unwrap().e += d;
				
				if node[u].lock().unwrap().e > 0 {
					excess.insert(0,u);
				}
				if node[v].lock().unwrap().e == d {
					excess.insert(0,v);
				}
				break;
			} else {
				v = u;
			}
		}
		if u != v {

		} else {
			node[u].lock().unwrap().h+=1;
			excess.insert(0,u);
			println!("Relabeling h = {}", node[u].lock().unwrap().h);
		}
	}

	println!("f = {}", node[t].lock().unwrap().e);

}
