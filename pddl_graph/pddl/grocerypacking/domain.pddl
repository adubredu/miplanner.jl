(define (domain grocery)
(:requirements :strips :equality)
(:predicates (on-table ?x)
             (arm-empty)
             (holding ?x)
             (in-bag ?x))



(:action pack
 :parameters (?ob)
 :precondition (and (on-table ?ob) (not (in-bag ?ob)))
 :effect (and (in-bag ?ob) (not (on-table ?ob)))

))
