;extensions [fetch import-a csv table ]

globals [
  nr-dem-shares-democrat ; number of democratic shares received for democrats
  nr-rep-shares-democrat ; number of republican shares received for democrats

  nr-dem-shares-republican ; number of democratic shares received for republicans
  nr-rep-shares-republican ;THESE 4 ARE THE OUTPUT OF THE MDOEL


nr-bias-changes
nr-new-democrats
nr-new-republicans
  ;sd-nr-rep-belief-republican ;probably a reporter rather than a global variable. we'll see.

]

breed [dem-medias dem-media]
breed [rep-medias rep-media]
breed [ppls ppl]


dem-medias-own [
  name
  my-ppls
  shared-bias
]

rep-medias-own [
  name
  my-ppls
  shared-bias
]

ppls-own [
  my-dem-medias
  my-rep-medias
  my-friends
  my-rep-friends
  my-dem-friends
  bias ; 2 levels, democrat or republican ""
  shared-bias ;what bias the ppl will emit this tick. 2levels, "dem" and "rep"
  ;my-attitude

  my-nr-dem-belief-democrat ;used for changing biases and attitudes in to go. Output measure still the global count.
  my-nr-rep-belief-democrat
  my-nr-dem-belief-republican
  my-nr-rep-belief-republican
  my-nr-dem-belief
  my-nr-rep-belief

]



to setup

  clear-all
  reset-ticks
  make-dem-medias
  make-rep-medias
  populate
  set-my-bias
  set-my-stations
  set-my-friends
  ;set-my-attitude ;didn't work

  make-network



end


to go
  set-shared-bias
  information-spread
  count-my-exposure
  update-bias
  color-bias

  ;update-my-attitude ;Attitude is bugged...
  ;reset-shared-bias ;DOESN^T WORK FOR SOME REASON. seems like the agents don't really share ;the bias the agent emits this tick - as a consequence of how many links or whether extremist or not
  tick

  if ticks = 8 [
    stop
  ]
end

to do-stuff
  set-my-stations-make-network
end

to set-shared-bias

  ;;; SETTING shared-bias each tick
  ask ppls [
;   ifelse my-attitude = "extremist" [
;   ;if extremist then democrats always share dem. republicans always share rep.
;   if bias = "democrat" [
;       set shared-bias "dem"
;      ]
;
;   if bias = "republican" [
;       set shared-bias "rep"
;      ]
;
;    ][ ;else

   if bias = "republican" [
      if count my-rep-medias > count my-dem-medias [
        set shared-bias "rep"  ;shared bias = what bias the ppl will emit this tick
      ]

   ifelse count my-dem-medias > count my-rep-medias and random-float 1 < 0.30 [ ;if more rep medias there is 30% chance that rep is shared
        set shared-bias "dem"
      ][
        set shared-bias "rep"

   ]
   ]
   ; ]





   if bias = "democrat" [
   if count my-dem-medias > count my-rep-medias [
        set shared-bias "dem"  ;shared bias = what bias the ppl will emit this tick
      ]

   ifelse count my-rep-medias > count my-dem-medias and random-float 1 < 0.30 [ ;if more rep medias there is 30% chance that rep is shared
        set shared-bias "rep"
      ][
        set shared-bias "dem"

    ]
  ] ; ending The bias = democrat in the else part of the first ifelse.

  ] ;ask ppls end
end

to information-spread

    ask ppls [
   ;if network-structure = "standard" [
   if bias = "democrat" [
      set nr-dem-shares-democrat nr-dem-shares-democrat + my-nr-dem-medias-standard-democrat
      set nr-dem-shares-democrat nr-dem-shares-democrat + count link-neighbors with [shared-bias = "dem"]

      set nr-rep-shares-democrat nr-rep-shares-democrat + my-nr-rep-medias-standard-democrat
      set nr-rep-shares-democrat nr-rep-shares-democrat + count link-neighbors with [shared-bias = "rep"]

  ]

   ;if network-structure = "standard" [
   if bias = "republican" [
      set nr-rep-shares-republican nr-rep-shares-republican + my-nr-rep-medias-standard-republican
      set nr-rep-shares-republican nr-rep-shares-republican + count link-neighbors with [shared-bias = "rep"]

      set nr-dem-shares-republican nr-dem-shares-republican + my-nr-dem-medias-standard-republican
      set nr-dem-shares-republican nr-dem-shares-republican + count link-neighbors with [shared-bias = "dem"]

  ]
  ]

end

to count-my-exposure
;;;; FOR UPDATE-MY-ATTITUDE AND UPDATE-BIAS
   ask ppls [

   if bias = "democrat" [
      set my-nr-dem-belief my-nr-dem-belief + my-nr-dem-medias-standard-democrat
      set my-nr-dem-belief my-nr-dem-belief + count link-neighbors with [shared-bias = "dem"]

      if random-float 1 < 0.30 [
      set my-nr-rep-belief my-nr-rep-belief + my-nr-rep-medias-standard-democrat
    ]
      if random-float 1 < 0.30 [
      set my-nr-rep-belief my-nr-rep-belief + count link-neighbors with [shared-bias = "rep"]


  ]
  ]
  ]

   ask ppls [

   if bias = "republican" [
      set my-nr-rep-belief my-nr-rep-belief + my-nr-rep-medias-standard-democrat
      set my-nr-rep-belief my-nr-rep-belief + count link-neighbors with [shared-bias = "rep"]

      if random-float 1 < 0.30 [
      set my-nr-dem-belief my-nr-dem-belief + my-nr-dem-medias-standard-democrat
      if random-float 1 < 0.30 [
      set my-nr-dem-belief my-nr-dem-belief + count link-neighbors with [shared-bias = "dem"]

  ]
  ]
  ]
  ]
end



;to update-my-attitude
;
; ask ppls [
;
; if (my-nr-rep-belief * extremist-x) < (my-nr-dem-belief) [
;    set my-attitude "extremist"
;  ]
;
; if (my-nr-dem-belief * extremist-x) < (my-nr-rep-belief) [
;    set my-attitude "extremist"
;    ]
;
;]
;
;end


to update-bias

 ask ppls [

  if (my-nr-dem-belief * bias-x) < my-nr-rep-belief and bias = "democrat" [
    set bias "republican"
    set nr-new-republicans nr-new-republicans + 1
    set nr-bias-changes nr-bias-changes + 1
    ]

 if (my-nr-rep-belief * bias-x) < my-nr-dem-belief and bias = "republican" [
    set bias "democrat"
    set nr-new-democrats nr-new-democrats + 1
    set nr-bias-changes nr-bias-changes + 1
  ]


]

end

to-report sd-nr-rep-belief-republican

end

;;                                  USED IN SETUP
to make-dem-medias

  ;let station-names ["1" "2" "3"]

  ;;positions:
  ;let plant-patches (patch-set patch -63 3 patch -30 10 patch 19 3 patch 44 8 patch 54 -32 patch 83 -33) ;;12 different positions @@ set positions
  ;set plant-patches sort-on [pxcor] plant-patches ;(from left to right based on pxcor)

  create-dem-medias 6 [
   set color blue ;set colour after name @@@
   set shape "house" set size 2 ;find better shape @@@
   ;set name first station-names
   ;set station-names but-first station-names ;removes the first item from the name list (since it's now taken) (this code block is run by one station at a time)
   ;set shared-bias "nothing"


   ;;positions:
   layout-circle turtles 10
   ;let plant-patches (patch-set patch 1 20 patch 20 10 patch 19 3) ;;12 different positions
   ;set plant-patches sort-on [pxcor] plant-patches ;(from left to right based on pxcor)
   ;setxy random-xcor random-ycor
   ;move-to first plant-patches
   ;set plant-patches but-first plant-patches
  ]

end

to make-rep-medias

  ;let station-names ["4" "5" "6"]

  ;;positions:
  ;let plant-patches (patch-set patch -63 3 patch -30 10 patch 19 3 patch 44 8 patch 54 -32 patch 83 -33) ;;12 different positions @@ set positions
  ;set plant-patches sort-on [pxcor] plant-patches ;(from left to right based on pxcor)

  create-rep-medias 6 [
   set color red ;set colour after name @@@
   set shape "house" set size 2 ;find better shape @@@
   ;set name first station-names
   ;set station-names but-first station-names ;removes the first item from the name list (since it's now taken) (this code block is run by one station at a time)
   ;set shared-bias "nothing"


    ;;positions
   layout-circle turtles 11
   ;setxy random-xcor random-ycor
    ;move-to first plant-patches
    ;set plant-patches but-first plant-patches
  ]

end

to populate ;;run in setup. Create starting population
  repeat nr-ppls [ make-person "ppls"]

end

to make-person [kind]
  if kind = "ppls" [
   create-ppls 1 [
   set shape "person" set size 1 set color white

   ;;positions
   layout-circle ppls 4
   ;setxy random-xcor random-ycor; location in the model @@
   ;set news-behaviour-group news-behaviour-groupp
  ]
  ]


end


to make-network
   ask ppls [
   create-links-with my-dem-medias
   create-links-with my-rep-medias
   create-links-with my-dem-friends
   create-links-with my-rep-friends
  ]

end

;;;                TO REPORTS FOR CREATING PPLS TO MEDIA NETWORK STRUCTURE
to-report my-nr-dem-medias-standard-democrat ; For the bias = democrat
  if network-structure = "standard" [
  let this-number random-float 1

      if this-number < standard-same-1 [ ;
        report 2 ;
        ]

  ;;
      if this-number >= standard-same-1 and this-number < standard-same-2 [ ;
        report 4 ;if report 1, then the person will get 1 bias1 in their set-my-stations. Hereby 1 bias1 in their network.
        ]

  ;;
      if this-number >= standard-same-2 [ ;
        report 6
        ]
  ]

  ;echo chamber reduction1

  if network-structure = "echo chamber reduction1" [
  let this-number random-float 1

    if this-number < echo1-same-1 [ ;
        report 2 ;
        ]

  ;;
      if this-number >= echo1-same-1 and this-number < echo1-same-2 [ ;
        report 4 ;if report 1, then the person will get 1 bias1 in their set-my-stations. Hereby 1 bias1 in their network.
        ]

  ;;
      if this-number >= echo1-same-2 [ ;
        report 6
        ]
  ]

  if network-structure = "echo chamber reduction2" [
  let this-number random-float 1

    if this-number < echo2-same-1 [ ;
        report 2 ;
        ]

  ;;
      if this-number >= echo2-same-1 and this-number < echo2-same-2 [ ;
        report 4 ;if report 1, then the person will get 1 bias1 in their set-my-stations. Hereby 1 bias1 in their network.
        ]

  ;;
      if this-number >= echo2-same-2 [ ;
        report 6
        ]
  ]

end

to-report my-nr-dem-medias-standard-republican ; For the bias = republican
  if network-structure = "standard"[
  let this-number random-float 1

      if this-number < standard-opposite-0 [ ;
        report 0 ;
        ]

  ;;
      if this-number >= standard-opposite-0 and this-number < standard-opposite-1 [ ;
        report 2 ;if report 1, then the person will get 1 bias1 in their set-my-stations. Hereby 1 bias1 in their network.
        ]

  ;;
      if this-number >= standard-opposite-1 and this-number < standard-opposite-2 [ ;
        report 4
        ]

  ;;
      if this-number >= standard-opposite-2 [ ;
        report 6
        ]

        ];standard end


  if network-structure = "echo chamber reduction1" [
  let this-number random-float 1

      if this-number < echo1-opposite-1 [ ;
        report 2 ;
        ]

  ;;
      if this-number >= echo1-opposite-1 and this-number < echo1-opposite-2 [ ;
        report 4 ;if report 1, then the person will get 1 bias1 in their set-my-stations. Hereby 1 bias1 in their network.
        ]

  ;;
      if this-number >= echo1-opposite-2 [ ;
        report 6
        ]

        ] ;echo chamber reduction1 end

  if network-structure = "echo chamber reduction2" [
  let this-number random-float 1

    if this-number < echo2-opposite-1 [ ;
        report 2 ;
        ]

  ;;
      if this-number >= echo2-opposite-1 and this-number < echo2-opposite-2 [ ;
        report 4 ;if report 1, then the person will get 1 bias1 in their set-my-stations. Hereby 1 bias1 in their network.
        ]

  ;;
      if this-number >= echo2-opposite-2 [ ;
        report 6
        ]
  ]

end

to-report my-nr-rep-medias-standard-democrat ; For the bias = democrats
  if network-structure = "standard" [
  let this-number random-float 1

      if this-number < standard-opposite-0 [ ;
        report 0 ;
        ]

  ;;
      if this-number >= standard-opposite-0 and this-number < standard-opposite-1 [ ;
        report 2 ;if report 1, then the person will get 1 bias1 in their set-my-stations. Hereby 1 bias1 in their network.
        ]

  ;;
      if this-number >= standard-opposite-1 and this-number < standard-opposite-2 [ ;
        report 4
        ]

  ;;
      if this-number >= standard-opposite-2 [ ;
        report 6
        ]

  ] ;STANDARD END

  if network-structure = "echo chamber reduction1" [
  let this-number random-float 1
        if this-number < echo1-opposite-1 [ ;
        report 2 ;
        ]

  ;;
      if this-number >= echo1-opposite-1 and this-number < echo1-opposite-2 [ ;
        report 4
        ]

  ;;
      if this-number >= echo1-opposite-2 [ ;
        report 6
        ]

        ] ;echo chamber reduction1 end


    if network-structure = "echo chamber reduction2" [
  let this-number random-float 1

    if this-number < echo2-opposite-1 [ ;
        report 2 ;
        ]

  ;;
      if this-number >= echo2-opposite-1 and this-number < echo2-opposite-2 [ ;
        report 4 ;if report 1, then the person will get 1 bias1 in their set-my-stations. Hereby 1 bias1 in their network.
        ]

  ;;
      if this-number >= echo2-opposite-2 [ ;
        report 6
        ]
  ]

end

to-report my-nr-rep-medias-standard-republican
  if network-structure = "standard" [
  let this-number random-float 1

      if this-number < standard-same-1 [ ;
        report 2 ;
        ]

  ;;
      if this-number >= standard-same-1 and this-number < standard-same-2 [ ;
        report 4 ;if report 1, then the person will get 1 bias1 in their set-my-stations. Hereby 1 bias1 in their network.
        ]

  ;;
      if this-number >= standard-same-2 [ ;
        report 6
        ]

  ] ;STANDARD END

  if network-structure = "echo chamber reduction1" [
  let this-number random-float 1
        if this-number < echo1-same-1 [ ;
        report 2 ;
        ]

  ;;
      if this-number >= echo1-same-1 and this-number < echo1-same-2 [ ;
        report 4
        ]

  ;;
      if this-number >= echo1-same-2 [ ;
        report 6
        ]

        ] ;echo chamber reduction1 end


    if network-structure = "echo chamber reduction2" [
  let this-number random-float 1

    if this-number < echo2-same-1 [ ;
        report 2 ;
        ]

  ;;
      if this-number >= echo2-same-1 and this-number < echo2-same-2 [ ;
        report 4 ;if report 1, then the person will get 1 bias1 in their set-my-stations. Hereby 1 bias1 in their network.
        ]

  ;;
      if this-number >= echo2-same-2 [ ;
        report 6
        ]
  ]

end


to set-my-stations
  ;if network-structure = "standard" [
  ask ppls [

    if bias = "democrat" [
    set my-dem-medias n-of my-nr-dem-medias-standard-democrat dem-medias
    set my-rep-medias n-of my-nr-rep-medias-standard-democrat rep-medias

    ]

    if bias = "republican" [
    set my-dem-medias n-of my-nr-dem-medias-standard-republican dem-medias
    set my-rep-medias n-of my-nr-rep-medias-standard-republican rep-medias
    ]
  ]


end



to set-my-stations-make-network
  ask ppls [

    if bias = "democrat" and my-nr-rep-medias-standard-democrat = 0 [
    ;set my-dem-medias n-of my-nr-dem-medias-standard-democrat dem-medias
    set my-rep-medias n-of 6 rep-medias

    ]

    if bias = "republican" and my-nr-dem-medias-standard-republican = 0 [
    ;set my-dem-medias n-of my-nr-dem-medias-standard-republican dem-medias
    set my-rep-medias n-of 6 rep-medias
    ]
  ]


 ask ppls [
   create-links-with my-dem-medias
   create-links-with my-rep-medias
  ]

end


;;;;;;;;;                                               TO REPORTS FOR PPLS TO PPLS NETWORK STRUCTURE
; IF i cannot run the model then i will prob have to make the amount of friends an abstraction. Meaning that it is a number corresponding to the amount of ppl in your network that you actually get something from
;on your startpage regularly. it wouldn't make sense to make a network with 300 friends pr. person - even though it might be the case in real life. This is because we would need to have 500k ppl+ in the model.
to-report my-dem-friends-standard-democrat ; for the bias = democrat

    let this-number random-float 1

      if this-number < 0.10 [ ;
        report friends-lower-bound ;
        ]

  ;;
      if this-number >= 0.10 and this-number < 0.55 [ ;
        report friends-medium-bound
        ]

  ;;
      if this-number >= 0.55 [ ;
        report friends-higher-bound
        ]

end

to-report my-dem-friends-standard-republican ; For the bias = republican

  let this-number random-float 1

      if this-number < 0.2 [ ;
        report 0 ;
        ]

  ;;
      if this-number >= 0.2 and this-number < 0.60 [ ;
        report friends-lower-bound ;
        ]

  ;;
      if this-number >= 0.60 and this-number < 0.80 [ ;
        report friends-medium-bound
        ]

  ;;
      if this-number >= 0.80 [ ;
        report friends-higher-bound
        ]


end


to-report my-rep-friends-standard-democrat ; For the bias = democrats

  let this-number random-float 1

      if this-number < 0.2 [ ;
        report 0 ;
        ]

  ;;
      if this-number >= 0.2 and this-number < 0.60 [ ;
        report friends-lower-bound
        ]

  ;;
      if this-number >= 0.60 and this-number < 0.80 [ ;
        report friends-medium-bound
        ]

  ;;
      if this-number >= 0.80 [ ;
        report friends-higher-bound
        ]

end

to-report my-rep-friends-standard-republican

  let this-number random-float 1

      if this-number < 0.10 [ ;
        report friends-lower-bound ;
        ]

  ;;
      if this-number >= 0.10 and this-number < 0.55 [ ;
        report friends-medium-bound ;
        ]

  ;;
      if this-number >= 0.55 [ ;
        report friends-higher-bound
        ]

end

to set-my-friends ; @@@


  ;if network-structure = "standard" [
  ask ppls [

    if bias = "democrat" [
    set my-dem-friends n-of my-dem-friends-standard-democrat other ppls with [(bias = "democrat")]
    set my-rep-friends n-of my-rep-friends-standard-democrat other ppls with [(bias = "republican")]

    ]

    if bias = "republican" [
    set my-dem-friends n-of my-dem-friends-standard-republican other ppls with [(bias = "democrat")]
    set my-rep-friends n-of my-rep-friends-standard-republican other ppls with [(bias = "republican")]
    ]
  ]
  ;]

end

to-report my-biass
  let this-number random-float 1
  ifelse this-number < 0.5 [
      report 1 ;;@swapped these around to check someting. 1 first then 2
  ][
      report 2
  ]


  ;if this-number
end

to set-my-bias
ask ppls [
ifelse my-biass = 1 [
  set bias "democrat"
  ]
  [
  set bias "republican"
  ]
  ]

end

to color-bias

  ask ppls [
   if bias = "democrat" [
     set color blue
    ]

   if bias = "republican" [
     set color red
    ]
  ]



end

;to-report my-attitudee
;  let this-number random-float 1
;  ifelse this-number < 0.80 [ ;80% of pop neutrals
;      report 1
;  ][
;      report 2
;  ]
;
;end
;
;to set-my-attitude
;ask ppls [
;    if my-attitudee = 1 [
;      set my-attitude "neutral"
;    ]
;
;      if my-attitudee = 2 [
;      set my-attitude "extremist"
;    ]
;  ]
;end
;to-report nr-extremists
;report count ppls with [my-attitude = "extremist"]
;end


to-report nr-democrats
report count ppls with [bias = "democrat"]
end

to-report nr-republicans
report count ppls with [bias = "republican"]
end

to-report nr-ppls-sharing-dem
report count ppls with [shared-bias = "dem"]
end

to-report nr-ppls-sharing-rep
report count ppls with [shared-bias = "rep"]
end

to-report nr-links
  report count links
end

to-report my-nr-links

report count link-neighbors


  ;ask ppls [
  ;  let
 ; ]

  ;report count links-with dem-medias
end
@#$#@#$#@
GRAPHICS-WINDOW
480
15
1094
630
-1
-1
18.364
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
125
142
188
175
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
200
142
264
176
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
169
21
224
81
nr-ppls
1000.0
1
0
Number

CHOOSER
260
28
448
73
network-structure
network-structure
"standard" "echo chamber reduction1" "echo chamber reduction2"
0

MONITOR
487
579
569
624
NIL
nr-links
17
1
11

MONITOR
488
25
638
70
NIL
nr-dem-shares-democrat
17
1
11

INPUTBOX
3
52
121
112
friends-lower-bound
2.0
1
0
Number

INPUTBOX
3
112
122
172
friends-medium-bound
4.0
1
0
Number

INPUTBOX
2
172
123
232
friends-higher-bound
8.0
1
0
Number

MONITOR
488
75
638
120
NIL
nr-rep-shares-democrat
17
1
11

MONITOR
930
24
1083
69
NIL
nr-rep-shares-republican
17
1
11

MONITOR
930
73
1085
118
NIL
nr-dem-shares-republican
17
1
11

INPUTBOX
276
176
433
236
bias-x
1.1
1
0
Number

MONITOR
994
578
1086
623
NIL
nr-republicans
17
1
11

MONITOR
994
531
1086
576
NIL
nr-democrats
17
1
11

MONITOR
867
532
991
577
NIL
nr-ppls-sharing-dem
17
1
11

MONITOR
867
577
991
622
NIL
nr-ppls-sharing-rep
17
1
11

PLOT
606
284
1089
625
% of total information received (y-value * 100 = % of total information)
time
% of total
0.0
10.0
0.2
0.3
true
true
"" ""
PENS
"Democrats receiving democratic info" 1.0 0 -13345367 true "" "if ticks > 0 [ plot nr-dem-shares-democrat / (nr-dem-shares-democrat + nr-rep-shares-democrat + nr-rep-shares-republican + nr-dem-shares-republican)]"
"Democrats receiving Republican info" 1.0 0 -11221820 true "" "if ticks > 0 [ plot nr-rep-shares-democrat / (nr-rep-shares-democrat + nr-dem-shares-democrat + nr-rep-shares-republican + nr-dem-shares-republican)]"
"Republican receiving Republican info" 1.0 0 -2674135 true "" "if ticks > 0 [ plot nr-rep-shares-republican / (nr-rep-shares-republican + nr-rep-shares-democrat + nr-dem-shares-democrat + nr-dem-shares-republican)]"
"Republicans receiving Democratic info" 1.0 0 -817084 true "" "if ticks > 0 [ plot nr-dem-shares-republican / (nr-dem-shares-republican + nr-dem-shares-democrat + nr-rep-shares-republican + nr-dem-shares-republican)]"

TEXTBOX
1261
14
1466
99
The % of people getting either 0, 2, 4 or 6 medias in their network\n(look under \"my-nr-dem-medias-standard-democrat\" to understand. 
14
0.0
1

INPUTBOX
1098
128
1228
188
standard-opposite-0
0.2
1
0
Number

INPUTBOX
1098
189
1228
249
standard-opposite-1
0.6
1
0
Number

INPUTBOX
1097
249
1229
309
standard-opposite-2
0.8
1
0
Number

INPUTBOX
1231
129
1386
189
standard-same-1
0.1
1
0
Number

INPUTBOX
1233
194
1388
254
standard-same-2
0.55
1
0
Number

INPUTBOX
1307
418
1403
478
echo1-opposite-1
0.6
1
0
Number

INPUTBOX
1305
480
1403
540
echo1-opposite-2
0.8
1
0
Number

INPUTBOX
1405
418
1507
478
echo1-same-1
0.1
1
0
Number

INPUTBOX
1406
481
1508
541
echo1-same-2
0.55
1
0
Number

INPUTBOX
1097
534
1200
594
echo2-opposite-1
0.33
1
0
Number

INPUTBOX
1098
597
1202
657
echo2-opposite-2
0.66
1
0
Number

INPUTBOX
1204
534
1285
594
echo2-same-1
0.33
1
0
Number

INPUTBOX
1205
597
1285
657
echo2-same-2
0.66
1
0
Number

TEXTBOX
1208
114
1358
132
Standard\n
11
0.0
1

TEXTBOX
1420
396
1570
414
echo1\n
11
0.0
1

TEXTBOX
1187
511
1337
529
echo2
11
0.0
1

PLOT
32
299
413
608
Number of changes in bias
Time
Number
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"default" 1.0 0 -14070903 true "" "if ticks > 0 [ plot nr-new-democrats ]"
"pen-1" 1.0 0 -5298144 true "" "if ticks > 0 [ plot nr-new-republicans ]"
"pen-2" 1.0 0 -1184463 true "" "if ticks > 0 [ plot nr-bias-changes ]"

BUTTON
265
74
466
107
NIL
do-stuff
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
