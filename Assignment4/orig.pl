    english2C(S,C) :- rec_parser(S,C).
     
    :-op(6,xfy,+).
    :-op(6,xfy,-).
    :-op(3,fy,+).
    :-op(3,fy,-).
    :-op(3,fy,~).
    :-op(5,xfy,*).
    :-op(5,xfy,'/').
    :-op(5,xfy,'%').
    :-op(7,xfy,<<).
    :-op(7,xfy,>>).
    :-op(10,xfy,&).
    :-op(11,xfy,^).
    :-op(12,xfy,!).
     
    con(to).
    con(and). 
    mul(by).
    mul(and).
     
    rec_parser([H|T],C):- T = [],C = H.
    rec_parser([add,I,X,J | T], C) :- integer(I),integer(J), rec_parser([I+J|T],C), con(X).
	rec_parser([subtract,I,from,J | T], C) :- integer(I),integer(J),rec_parser([J-I|T],C).
    rec_parser([negative,of,I | T], C) :- integer(I),rec_parser([-I|T],C).
    rec_parser([I,unaltered | T], C) :- integer(I),rec_parser([+I|T],C),integer(I).
    rec_parser([complement,of,I | T], C) :- integer(I),rec_parser([~I|T],C).
   
    rec_parser([multiply,I,X,J | T], C) :- integer(I),integer(J),rec_parser([I*J|T],C), mul(X).
    rec_parser([divide,I,by,J | T], C) :- integer(I),integer(J),rec_parser([I/J|T],C).
    
    rec_parser([take,the,remainder,of,I,after,dividing,by,J | T], C) :- integer(I),integer(J),rec_parser([I '%' J|T],C).
    rec_parser([I,shifted,left,J,bits | T], C) :- integer(I),integer(J),rec_parser([I<<J|T],C).
    rec_parser([I,shifted,right,J,bits | T], C) :- integer(I),integer(J),rec_parser([I>>J|T],C).
    rec_parser([I,and,J | T], C) :- integer(I),integer(J),rec_parser([I&J|T],C).    
    rec_parser([I,exclusive,or,J | T], C) :- integer(I),integer(J),rec_parser([I^J|T],C).
    rec_parser([I,or,J | T], C) :- integer(I),integer(J), rec_parser([I!J|T],C).   
    rec_parser([discard,I,then,use,J,instead | T], C) :- integer(I),integer(J),rec_parser([(I,J)|T],C).
     
    rec_parser([E,',',then,add,J | T], C) :- integer(J), rec_parser(E, A), rec_parser([A+J|T],C).
    rec_parser([E,',',then,subtract,J | T], C) :- integer(J),rec_parser(E, A),rec_parser([A-J|T],C).
    rec_parser([E,',',then,do,nothing | T], C) :- rec_parser([+E|T],C).
    rec_parser([E,',',then,negate,it | T], C) :-  rec_parser([-E|T],C).
    rec_parser([E,',',then,complement,it | T], C) :- rec_parser([~E|T],C).  /*!!!!*/
    rec_parser([E,',',then,multiply,by,J | T], C) :- integer(J),rec_parser([E*J|T],C).
    rec_parser([E,',',then,divide,by,J | T], C) :- integer(J),rec_parser([E/J|T],C).
    rec_parser([E,',',then,divide,by,J,and,take,the,remainder | T], C) :- integer(J),rec_parser([E'%'J|T],C). 
    rec_parser([E,',',then,shift,left,J,bits | T], C) :- integer(J),rec_parser([E<<J|T],C).
    rec_parser([E,',',then,shift,right,J,bits | T], C) :- integer(J),rec_parser([E>>J|T],C).
    rec_parser([E,',',then,and,with,J | T], C) :- integer(J),rec_parser([E&J|T],C). /*!!!!*/
    rec_parser([E,',',then,exclusive,or,with,J | T], C) :- integer(J),rec_parser([E^J|T],C).
    rec_parser([E,',',then,or,with,J | T], C) :- integer(J),rec_parser([E!J|T],C).  /*!!!!*/
    rec_parser([E,',',then,discard,and,use,J,instead | T], C) :- integer(J),rec_parser([(E,J)|T],C).
