import scala.util._
import java.util.Scanner
import java.io._
import akka.actor._
import akka.pattern.ask
import akka.util.Timeout
import scala.concurrent.{Await,ExecutionContext,Future,Promise}
import scala.concurrent.duration._
import scala.language.postfixOps
import scala.collection.mutable.Map
import scala.io._


case class Flow(f: Int)
case class Debug(debug: Boolean)
case class Control(control:ActorRef)
case class Source(n: Int)
case class Increase(f: Int)
case class Height(h: Int)
case class Push(h: Int, pushVal: Int, ed: Edge)

case object Print
case object PushMax
case object Start
case object Excess
case object Maxflow
case object Sink
case object H
case object CheckFlow
case object InitializeFlow
case object ACKPush
case object NACKPush
case object Done
case object NoLongerDone
case object PrintNoLongerFinished
case object PrintFinished

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
    var isDone = false
	var buffer:Map[ActorRef,Int] = Map()
	var counter:Int = 0
    def min(a:Int, b:Int) : Int = { if (a < b) a else b }

	def id: String = "@" + index;

	def other(a:Edge, u:ActorRef) : ActorRef = { if (u == a.u) a.v else a.u }

	def status: Unit = { if (debug) println(id + " e = " + e + ", h = " + h) }

	def enter(func: String): Unit = { if (debug) { println(id + " enters " + func); status } }
	def exit(func: String): Unit = { if (debug) { println(id + " exits " + func); status } }

	def relabel : Unit = {

		enter("relabel")

		h += 1

		exit("relabel")
	}

    def addToBuffer(key: ActorRef, value: Int) : Boolean = {
		if (buffer.contains(key)){
			if(debug) println(id+" alread has"+key)
			return false
		}
        e -= value
        buffer += (key -> value)
		return true
    }



	def receive = {

	case Debug(debug: Boolean)	=> this.debug = debug

	case Print => status

	case Excess => { sender ! Flow(e) /* send our current excess preflow to actor that asked for it. */ }

	case edge:Edge => { this.edge = edge :: this.edge /* put this edge first in the adjacency-list. */ }

	case Control(control:ActorRef)	=> this.control = control

	case Sink	=> { sink = true }

	case Source(n:Int)	=> { h = n; source = true }

    // New Method calls

    case InitializeFlow => {
        //Push maximum to all edges
        for (ed <- edge){
            other(ed, self) ! Push(h, ed.c, ed)
        }
    }
    
    case Push(h: Int, pushVal: Int, ed: Edge) => { //push is any value
        if (isDone){
            control ! NoLongerDone
			isDone = false
        }
        if (this.h>=h || (e+pushVal<0 && !source)){
            sender ! NACKPush
            if (buffer.isEmpty && e==0 && !isDone){
                control ! Done
				isDone = true
            }
        }
        else{
            sender ! ACKPush
            ed.f += pushVal
            e += pushVal
			}
		if (buffer.isEmpty && e>0){
			self ! CheckFlow
		}
    }

    case CheckFlow => {
		counter = 0
        if (e==0 || sink || source){
            if(buffer.isEmpty && !isDone){
				control ! Done
				isDone = true
			}
        } else {
        for (ed <- edge){
            other(ed, self) ! H //Ask everyone for 
        }
		}
    }
    case H => {
        // we want to respond with our height
        sender ! Height(h)
    }
    
    case Height(h: Int) => {
		//if (debug)println(id+"Our height:"+this.h+" recieved Height("+h+")")
		if (e == 0 || !buffer.isEmpty){

		}
        else if (this.h>h){ //sink =0 , source = 3, h = 1, node2 = 0
            var target:Edge = null
            var d:Int = 0
			for (ed <- edge){
				if (ed.v == sender) {
                    target = ed
                    d = min(e,ed.c-ed.f)
                    }
				if (ed.u == sender) {
                    target = ed
                    d = min(e,ed.c+ed.f)
                    }
			}
            if (target != null && d != 0){
                val b = addToBuffer(sender, d) //this will add this to the buffer
                if (b) sender ! Push(this.h, d, target)
            } else {
				counter +=1
				if(counter == edge.size){
					relabel
					self ! CheckFlow
					counter = 0
				}
				if (target == null){
					if(debug) println("TARGET IS NULL!")
				}
			}

        } else {
			counter+=1
			if(counter == edge.size){
            relabel
			self ! CheckFlow
			counter = 0
			}
        }
		
    }
    case ACKPush => {
        buffer.remove(sender)
        if (buffer.isEmpty){
			self ! CheckFlow
		}
    }
    case NACKPush => {
        e+=buffer(sender)
        buffer.remove(sender)
		if (buffer.isEmpty){
			self ! CheckFlow
		}
    }
	case PrintFinished => {
		println(id + "is finished")
	}
	case PrintNoLongerFinished => {
		println(id + "is waking up")
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
	var unfinishedNodes:Int = 0
	def receive = {

	case node:Array[ActorRef]	=> {
		this.node = node
		n = node.size
		s = 0
		t = n-1
        unfinishedNodes = n
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
		node(s) ! InitializeFlow
		

	}

    case Done => {
        unfinishedNodes-=1
        if (unfinishedNodes == 0){
            node(t) ! Excess
        }
    }
    case NoLongerDone => {
        unfinishedNodes+=1
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
