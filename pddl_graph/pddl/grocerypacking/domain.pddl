(define (domain grocery)
(:requirements :strips :equality)
(:predicates (on-table ?x)
             (arm-empty)
             (holding ?x)
             (in-bag ?x))

(:action pickup
 :parameters (?ob)
 :precondition (and (on-table ?ob) (arm-empty))
 :effect (and (holding ?ob) (not (on-table ?ob))
              (not (arm-empty))))

(:action put-in-bag
  :parameters  (?ob)
  :precondition (and (holding ?ob))
  :effect (and (clear ?ob) (arm-empty) (in-bag ?ob)
               (not (holding ?ob))))
)
