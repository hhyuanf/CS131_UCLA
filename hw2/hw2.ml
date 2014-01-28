type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let rec fun_gen rule_list result non_terminal = 
match rule_list with
[] -> result
|(a::b) -> match a with
(c,d) -> if c == non_terminal then fun_gen b (result@[d]) non_terminal
else fun_gen b result non_terminal

let convert_grammar gram1 = 
match gram1 with
(a,b) -> (a, fun_gen b [])

let match_nothing frag d accept = None

let append_matchers matcher1 rules matcher2 accept d frag =
  matcher1 rules (fun frag1 -> matcher2 accept frag1) d frag

let rec make_appended_matchers rule g accept d frag = 
match rule with 
[] -> accept d frag
|(T x)::t -> begin match frag with 
	[]->None
	|h::l -> if x = h then make_appended_matchers t g accept d l
		else None
	end
|(N x)::t ->  match frag with
	[]->None
	|_->append_matchers (make_or_matchers x g) (g x) (make_appended_matchers t g) accept d frag 		
and make_or_matchers start g = function
[] -> match_nothing
|h::t -> 
	let head_matcher = make_appended_matchers h g 
	and tail_matcher = make_or_matchers start g t 
	in fun accept d frag ->
		let ormatch = head_matcher accept (d@[(start, h)]) frag 
		in match ormatch with
			None -> tail_matcher accept d frag
			|Some (x,y) -> Some (x,y)
			
let parse_prefix (start, g) accept frag= make_or_matchers start g (g start) accept [] frag