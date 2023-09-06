import scala.util._
import java.util.Scanner
import java.io._
import akka.actor._
import akka.pattern.ask
import akka.util.Timeout
import scala.concurrent.{Await,ExecutionContext,Future,Promise}
import scala.concurrent.duration._
import scala.language.postfixOps
import scala.collection.mutable.Set
import scala.io._

case class Flow(f: Int)
case class Debug(debug: Boolean)
case class Control(control:ActorRef)
case class Source(n: Int)
case class Increase(f: Int)
case class Height(h: Int)
case class AreYouDone(i: Int)
case class AmDone(i: Int, b: Boolean)
case class Complete(i: Int)

case object Print
case object PushMax
case object Start
case object Excess
case object Maxflow
case object Sink
case object Hello
case object H
case object PreflowPush
case object IsDone
case object IsAlive

class Edge(var u: ActorRef, var v: ActorRef, var c: Int) {
	var	f = 0

	def setfMax: Unit = {
		this.f = this.c
	}
}

class Node(val index: Int) extends Actor {
	var	e = 0;				/* excess preflow. 						*/
	var	h = 0;				/* height. 							*/
	var	control:ActorRef = null		/* controller to report to when e is zero. 			*/
	var	source:Boolean	= false		/* true if we are the source.					*/
	var	sink:Boolean	= false		/* true if we are the sink.					*/
	var	edge: List[Edge] = Nil		/* adjacency list with edge objects shared with other nodes.	*/
	var	debug = true			/* to enable printing.						*/
	var counter = 0
	var isDone = true
	def min(a:Int, b:Int) : Int = { if (a < b) a else b }

	def id: String = "@" + index;

	def other(a:Edge, u:ActorRef) : ActorRef = { if (u == a.u) a.v else a.u }

	def status: Unit = { if (true) println(id + " e = " + e + ", h = " + h) }

	def enter(func: String): Unit = { if (debug) { println(id + " enters " + func); status } }
	def exit(func: String): Unit = { if (debug) { println(id + " exits " + func); status } }

	def increase(f: Int): Unit = {
		this.e = this.e + f
		self ! PreflowPush
	}

	def relabel : Unit = {

		enter("relabel")

		h += 1

		exit("relabel")
	}

	def push(ed : Edge,  v : ActorRef): Int = {
		control ! IsAlive
		if (self == ed.u){ //Positive flow // u == self
			val d = min(e,ed.c-ed.f)
			if (d <= 0){
				return 0
			}
			ed.f+=d
			v ! Increase(d)
			increase(-d)
			return d
		}else { //negative flow
			val d = min(e,ed.c+ed.f)
			if (d <= 0){
				return 0
			}
			ed.f-=d
			v ! Increase(d)
			increase(-d)
			return d
		}
	}

	def receive = {

	case Debug(debug: Boolean)	=> this.debug = debug

	case Print => status

	case Excess => { sender ! Flow(e) /* send our current excess preflow to actor that asked for it. */ }

	case edge:Edge => { this.edge = edge :: this.edge /* put this edge first in the adjacency-list. */ }

	case Control(control:ActorRef)	=> this.control = control

	case Sink	=> { sink = true }

	case Source(n:Int)	=> { h = n; source = true }

	case H => {
		sender ! Height(h)
	}

	case PreflowPush => {
		if (e == 0 || sink || source){
			control ! IsDone
		}else{
			counter = 0
			for (neigh <- edge){
				other(neigh, self) ! H
			}
		}
	}

	case Height(h:Int) => {
		if (h<this.h){
			var target:Edge = null
			for (e <- edge){
				if (e.v == sender) target = e
				if (e.u == sender) target = e
			}
			if (target == null){} 
			else{
				val d = push(target, sender) // Edge, Recieving Node
				if (d==0){
					counter+=1
					self ! PreflowPush
				}
			}
			
		} else {
			counter+=1
			if (counter >= edge.length){
				relabel
				self ! PreflowPush
			}
		}
	}

	case PushMax => {
		for (e <- edge){
			e.setfMax
			other(e, self) ! Increase(e.f)
		}
	}
	case AreYouDone(counter: Int) => {
		if(source || sink || e == 0){
			sender ! AmDone(counter, true)
		} else {
			sender ! AmDone(counter, false)
		}
	}

	case Increase(f:Int) => {
		this.e = this.e + f
		self ! PreflowPush
	}

	case _		=> {
		println("" + index + " received an unknown message" + _) }

		assert(false)
	}

}


class Preflow extends Actor
{
	var	s	= 0;			/* index of source node.					*/
	var	t	= 0;			/* index of sink node.					*/
	var	n	= 0;
	var counter = 0;			/* number of vertices in the graph.				*/
	var	edge:Array[Edge]	= null	/* edges in the graph.						*/
	var	node:Array[ActorRef]	= null	/* vertices in the graph.					*/
	var	ret:ActorRef 		= null	/* Actor to send result to.					*/
	var unfinishedNodes:Set[ActorRef] = Set()
	def receive = {

	case node:Array[ActorRef]	=> {
		this.node = node
		n = node.size
		s = 0
		t = n-1
		for (u <- node)
			u ! Control(self)
	}

	case edge:Array[Edge] => this.edge = edge

	case Flow(f:Int) => {
		ret ! f			/* somebody (hopefully the sink) told us its current excess preflow. */
	}

	case Maxflow => {
		ret = sender
		node(s) ! Source(n)
		node(t) ! Sink
		node(s) ! PushMax

	}
	case IsAlive => {
		counter+=1
	}

	case IsDone => {
		unfinishedNodes = Set()
		counter += 1
		for (nd <- node){
			nd ! AreYouDone(counter)
			unfinishedNodes+=nd
		}
	}
	case AmDone(counter: Int, done: Boolean) => {
		if(done && counter == this.counter){
			unfinishedNodes-=sender
		}
		if(unfinishedNodes.isEmpty){
			self ! Complete(counter)
		}
	}

	case Complete(counter:Int) => {
		if (counter == this.counter) node(t) ! Excess
	}
	}
}

object main extends App {
	implicit val t = Timeout(4 seconds);

	val	begin = System.currentTimeMillis()
	val system = ActorSystem("Main")
	val control = system.actorOf(Props[Preflow], name = "control")

	var	n = 0;
	var	m = 0;
	var	edge: Array[Edge] = null
	var	node: Array[ActorRef] = null

	val	s = new Scanner(System.in);

	n = s.nextInt
	m = s.nextInt

	/* next ignore c and p from 6railwayplanning */
	s.nextInt
	s.nextInt

	node = new Array[ActorRef](n)

	for (i <- 0 to n-1)
		node(i) = system.actorOf(Props(new Node(i)), name = "v" + i)

	edge = new Array[Edge](m)

	for (i <- 0 to m-1) {

		val u = s.nextInt
		val v = s.nextInt
		val c = s.nextInt

		edge(i) = new Edge(node(u), node(v), c)

		node(u) ! edge(i)
		node(v) ! edge(i)
	}

	control ! node
	control ! edge

	val flow = control ? Maxflow
	val f = Await.result(flow, t.duration)

	println("f = " + f)

	system.stop(control);
	system.terminate()

	val	end = System.currentTimeMillis()

	println("t = " + (end - begin) / 1000.0 + " s")
}
