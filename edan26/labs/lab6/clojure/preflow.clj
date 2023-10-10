(require '[clojure.string :as str])		; for splitting an input line into words

(def debug true)

(defn prepend [list value] (cons value list))	; put value at the front of list

(defrecord node [i e h adj])			; index excess-preflow height adjacency-list

(defn node-adj [u] (:adj u))			; get the adjacency-list of a node
(defn node-height [u] (:h u))			; get the height of a node
(defn node-excess [u] (:e u))			; get the excess-preflow of a node

(defn has-excess [u nodes]
	(> (node-excess @(nodes u)) 0))

(defrecord edge [u v f c])			; one-node another-node flow capacity
(defn edge-flow [e] (:f e))			; get the current flow on an edge
(defn edge-capacity [e] (:c e))			; get the capacity of an edge

; read the m edges with the normal format "u v c"
(defn read-graph [i m nodes edges]
	(if (< i m)
		(do	(let [line 	(read-line)]			
			(let [words	(str/split line #" ") ]

			(let [u		(Integer/parseInt (first words))]
			(let [v 	(Integer/parseInt (first (rest words)))]
			(let [c 	(Integer/parseInt (first (rest (rest words))))]
			
			(ref-set (edges i) (update @(edges i) :u + u))
			(ref-set (edges i) (update @(edges i) :v + v))
			(ref-set (edges i) (update @(edges i) :c + c))

			(ref-set (nodes u) (update @(nodes u) :adj prepend i))
			(ref-set (nodes v) (update @(nodes v) :adj prepend i)))))))

			; read remaining edges
			(recur (+ i 1) m nodes edges))))

(defn other [edge u]
	(if (= (:u edge) u) (:v edge) (:u edge)))

(defn u-is-edge-u [edge u]
	(= (:u edge) u))

(defn increase-flow [edges i d]
	(ref-set (edges i) (update @(edges i) :f + d)))

(defn decrease-flow [edges i d]
	(ref-set (edges i) (update @(edges i) :f - d)))

(defn move-excess [nodes u v d]
	(ref-set (nodes u) (update @(nodes u) :e - d))
	(ref-set (nodes v) (update @(nodes v) :e + d)))

(defn increase-excess [nodes u d]
	(ref-set (nodes u) (update @(nodes u) :e + d))
)

(defn insert [excess-nodes v]
	(ref-set excess-nodes (cons v @excess-nodes)))

(defn check-insert [excess-nodes v s t]
	(if (and (not= v s) (not= v t))
		(insert excess-nodes v)))

(defn push [edge-index u nodes edges excess-nodes change s t]
	(let [v 	(other @(edges edge-index) u)]
	(let [uh	(node-height @(nodes u))]
	(let [vh	(node-height @(nodes v))]
	(let [e 	(node-excess @(nodes u))]
	(let [i		edge-index]
	(let [f 	(edge-flow @(edges i))]
	(let [c 	(edge-capacity @(edges i))]

	(if debug
		(do
			(println "--------- push -------------------")
			(println "i = " i)
			(println "u = " u)
			(println "uh = " uh)
			(println "e = " e)
			(println "f = " f)
			(println "c = " c)
			(println "v = " v)
			(println "vh = " vh)))
	(let [d (min e (- c f))]
	(move-excess nodes u v d)
	(if (has-excess u nodes) (do (check-insert excess-nodes u s t)))
	(if (== d (node-excess @(nodes v))) (do (check-insert excess-nodes v s t)))
	
	)))))))))


; go through adjacency-list of source and push
(defn initial-push [adj s t nodes edges excess-nodes]
	(let [change (ref 0)] ; unused for initial pushes since we know they will be performed
	(if (not (empty? adj))
		(do 
			; give source this capacity as excess so the push will be accepted
			(increase-excess nodes s (edge-capacity @(edges (first adj))))
			(push (first adj) s nodes edges excess-nodes change s t)
			(initial-push (rest adj) s t nodes edges excess-nodes)))))

(defn initial-pushes [nodes edges s t excess-nodes]
	(initial-push (node-adj @(nodes s)) s t nodes edges excess-nodes))

(defn remove-any [excess-nodes]
	(dosync 
		(let [ u (ref -1)]
			(do
				(if (not (empty? @excess-nodes))
					(do
						(ref-set u (first @excess-nodes))
						(ref-set excess-nodes (rest @excess-nodes))))
			@u))))

; read first line with n m c p from stdin

(def line (read-line))

; split it into words
(def words (str/split line #" "))

(def n (Integer/parseInt (first words)))
(def m (Integer/parseInt (first (rest words))))

(def s 0)
(def t (- n 1))
(def excess-nodes (ref ()))

(def nodes (vec (for [i (range n)] (ref (->node i 0 (if (= i 0) n 0) '())))))

(def edges (vec (for [i (range m)] (ref (->edge 0 0 0 0)))))

(defn try-push [u nodes adj-edge edges excess-nodes s t]
	(let [v 	(other @(edges adj-edge) u)]
	(let [uh	(node-height @(nodes u))]
	(let [vh	(node-height @(nodes v))]
	(if (> uh vh) (do 
	(push adj-edge u nodes edges excess-nodes 0 s t)
	1
	))
	(do 0)
	))))

(defn relabel [u nodes]
(ref-set (nodes u) (update @(nodes u) :h + 1))
(println "Relabel")
)





(defn rec-edge [u nodes adj edges excess-nodes change s t]
(if (not (empty? adj))
(let [updated-change (try-push u nodes (first adj) edges excess-nodes s t)]
(rec-edge u nodes (rest adj) edges excess-nodes updated-change s t)
))
(if (and (empty? adj) (== change 0))
	(relabel u nodes)
	(check-insert excess-nodes u s t)
)
)


(dosync (read-graph 0 m nodes edges))

(defn preflow []

	(dosync (initial-pushes nodes edges s t excess-nodes))

	(while (not (empty? @excess-nodes))
		(let [u (remove-any excess-nodes)]
			(rec-edge u nodes (node-adj @(nodes u)) edges excess-nodes 0 s t)
		)
	)

	(println "f =" (node-excess @(nodes t))))

(preflow)
