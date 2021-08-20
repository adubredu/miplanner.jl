(define (domain grocery)
(:requirements :strips :equality)
(:predicates (ontable ?x)
             (arm-empty)
             (holding ?x)
             (inbag ?x))



(:action pack
 :parameters (?ob)
 :precondition (and (ontable ?ob) (not (inbag ?ob)))
 :effect (and (inbag ?ob) (not (ontable ?ob)))

))
