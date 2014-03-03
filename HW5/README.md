Continuation-based fragment analyzer
==========

Introduction

This homework builds on the hint for Homework 2. That hint contained a simple pattern-matcher generator for DNA fragments. Your generator will also take a pattern and produce a pattern-matcher. However, your pattern-matcher will operate in a different way from the hint, a way that is more convenient for some applications.

As before, the key notion of this assignment is that of a matcher, which in this assignment is a procedure that inspects a given list to find a match for a list prefix that corresponds to a pattern; if it fails it returns #f and if it succeeds it returns a pair containing (1) the corresponding list suffix and (2) a backtracker to be used if the list suffix is not acceptable. For example, a matcher M for the pattern (or c a) succeeds only on a list whose car is c or a, returning a pair consisting of (1) the cdr of that list and (2) a backtracker.

After a matcher M succeeds, it can be backtracked into by invoking the backtracker that it returned. This tells the matcher to backtrack and to return the next match for the pattern, using the same format as the first match. For example, the following code:

  (let ((match-result (M frag)))
    (if match-result
	(let ((suffix (car match-result))
	      (backtrack (cdr match-result)))
	  (if (and (pair? suffix) (eq? (car suffix) 'g))
	      (backtrack))))
    match-result)
calls M on a fragment and returns the first match whose corresponding suffix does not begin with g. This code will cause the example matcher to fail on (a g) but succeed on (c t).

As you can see by mentally executing the (a g) example, matchers sometimes need to try multiple alternatives and, when backtracked into, to return a later alternative if an earlier one is a blind alley.

Definitions

nucleotide
one of the four symbols a, c, g, and t, which stand for adenine, thymine, cytosine, and guanine, respectively. Please see "Nucleotide" for more.
DNA fragment
a list of nucleotides.
DNA pattern
an object that represents a set of DNA fragments. It is said to match each such fragment. It takes one of the following forms:
a, c, g, t
A nucleotide nt matches the singleton list (nt). For example, a matches (a).
(junk k)
matches up to k nucleotides. k must be a nonnegative integer. If there are several possible matches, it uses the shortest match. For example, (junk 0) matches only the empty list (), and (junk 2) matches (), (a), (c), (g), (t), (a a), (a c), (a g), (a t), (c a), (c c), (c g), (c t), (g a), (g c), (g g), (g t), (t a), (t c), (t g), and (t t).
(or pat …)
matches any DNA fragment that any DNA pattern pat matches. If more than one pat matches, it uses the first match. For example, (or) does not match any list, and (or a g t) matches (a), (g), and (t).
(list pat …)
matches any concatenation of DNA fragments that are matched by each pat, respectively. If there are several possible matches, (list pat1 pat2 …) uses the first match for pat1 that is acceptable to (list pat2 …). For example, (list), which has zero patterns, matches only the empty list (), and (list a (junk 1) (or a t)) matches (a a), (a t), (a a a), (a a t), (a c a), (a c t), (a g a), (a g t), (a t a), and (a t t).
(* pat)
matches any concatenation of nonnull DNA fragments that are each matched by pat. If the matched concatenation is of one or more fragments, this pattern is equivalent to (list pat (* pat)). If there are several possible concatenations, it uses the concatenation of the least number of fragments. It therefore always matches the empty fragment first. For example, (* (or g (list a t))) matches (), (g), (a t), (g g), (g a t), (a t g), (a t a t), ….
A DNA pattern is not a procedure call. For example, you do not need to define a procedure called junk. The symbol junk is part of the DNA pattern (junk 1), but junk does not need to be defined as a procedure.

matcher
a procedure M with one argument, a DNA fragment frag. When M matches a prefix of frag of length k it returns (cons (list-tail frag k) backtrack) where backtrack is a backtracker to be used if the tail is not acceptable. The matcher first returns the first match (according to the above rules); each time that it is backtracked into by means of (backtrack) the matcher returns the next match; when there are no more matches, the matcher returns #f.
backtracker
a parameterless procedure that causes the corresponding matcher to return its next match, as described above.
Each application of a matcher to a fragment should maintain its own set of backtrack points, which operate independently from any other application of matcher to fragment.

Assignment

Write a procedure (make-matcher pat) that returns a matcher for the DNA pattern pat. When applied to a DNA fragment frag, the matcher should return #f if there is no match, and a pair of the form (suffix . fail) if there is a match. Here, suffix is the unmatched suffix after the first match of a prefix of frag, using the definition of "first" given by the DNA pattern rules described above; this is not necessarily the shortest nor the longest match. The matcher should handle backtracking as described above. For example, (let ((r ((make-matcher 'a) '(a g)))) (and r ((cdr r)))) should return #f, because the matcher is backtracked into immediately after it succeeds, and it then fails.

Your implementation of make-matcher must be free of side affects and should avoid using unnecessary storage. Tail recursion is desirable but is not required, and you will probably find it necessary to use non-tail-recursive procedures both in make-matcher and in the matchers that make-matcher returns.

The matchers that make-matcher returns should be as simple as possible. Whenever any work could be done in either make-matcher or in the generated matcher, the work should be done in make-matcher. The generated matcher may use side effects, but they should be kept as simple and isolated as possible. It is OK for generated matchers to call helper functions that you define, and to have internal state variables; these helper functions and variables should follow the same rules as the generated matchers.

In all cases it is an error if procedure arguments are not of the proper form. For example, it is an error if the argument to make-matcher is not a DNA pattern, or if the first argument to a matcher is not a DNA fragment, or if an argument is passed to a backtracker. Your solution can assume that make-matcher and the matchers it returns and the backtrackers they return are given valid arguments by the test program; however, you must insure that these functions do not cause any errors when given valid arguments.
