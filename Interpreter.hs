module Interpreter where 

import Lexer 
import Parser

isValue :: Expr -> Bool
isValue BTrue   = True
isValue BFalse  = True
isValue (Num _) = True
isValue (Lam _ _ _) = True
isValue _       = False

subst :: String -> Expr -> Expr -> Expr 
subst x n (Var v) = if (x == v) then
                      n 
                    else 
                      (Var v)
subst x n (Lam v t b)     = Lam v t (subst x n b)
subst x n (App e1 e2)     = App (subst x n e1) (subst x n e2)
subst x n (Add e1 e2)     = Add (subst x n e1) (subst x n e2)
subst x n (And e1 e2)     = And (subst x n e1) (subst x n e2)
subst x n (If e1 e2 e3)   = If (subst x n e1) (subst x n e2) (subst x n e3)
subst x n (Paren e)       = Paren (subst x n e)
subst x n (Let v e1 e2)   = Let v (subst x n e1) (subst x n e2)
subst x n (Sub e1 e2)     = Sub (subst x n e1) (subst x n e2)
subst x n (Mul e1 e2)     = Mul (subst x n e1) (subst x n e2)
subst x n (Div e1 e2)     = Div (subst x n e1) (subst x n e2)
subst x n (Bigger e1 e2)  = Bigger (subst x n e1) (subst x n e2)
subst x n (Smaller e1 e2) = Smaller (subst x n e1) (subst x n e2)
subst x n (While cont e2) = While (subst x n cont) (subst x n e2)
subst x n (List ls) = List (map (subst x n) ls)
subst x n e = e 

funDiv :: Int -> Int -> Int
funDiv x y = x `div` y

step :: Expr -> Expr
step (Add (Num n1) (Num n2)) = Num (n1 + n2)
step (Add (Num n) e) = Add (Num n) (step e)
step (Add e1 e2) = Add (step e1) e2

step (Sub (Num n1) (Num n2)) = Num (n1 - n2)
step (Sub (Num n) e) = Sub (Num n) (step e)
step (Sub e1 e2) = Sub (step e1) e2

step (Mul (Num n1) (Num n2)) = Num (n1 * n2)
step (Mul (Num n) e) = Mul (Num n) (step e)
step (Mul e1 e2) = Mul (step e1) e2

step (Div (Num n1) (Num n2)) = Num (funDiv n1 n2)
step (Div (Num n) e) = Div (Num n) (step e)
step (Div e1 e2) = Div (step e1) e2

step (And BFalse _) = BFalse
step (And BTrue e) = e
step (And e1 e2) = And (step e1) e2

step (Or BTrue _) = BTrue
step (Or _ BTrue) = BTrue
step (Or BFalse e) = e
step (Or e BFalse) = e
step (Or e1 e2) = Or (step e1) e2 

step (If BFalse e1 e2) = e2
step (If BTrue e1 e2) = e1
step (If e e1 e2) = If (step e) e1 e2

step (Paren e) = e
step (App (Lam x t b) e2)   | isValue e2 = subst x e2 b
                            | otherwise = (App (Lam x t b) (step e2))
step (App e1 e2) = App (step e1) e2
step (Let v e1 e2) | isValue e1 = subst v e1 e2
                   | otherwise = Let v (step e1) e2

step (Bigger (Num n1) (Num n2)) = if n1 > n2 then BTrue else BFalse
step (Bigger (Num n) e2) = Bigger (Num n) (step e2)
step (Bigger e1 e2) = Bigger (step e1) e2

step (Smaller (Num n1) (Num n2)) = if n1 < n2 then BTrue else BFalse
step (Smaller (Num n) e2) = Smaller (Num n) (step e2)
step (Smaller e1 e2) = Smaller (step e1) e2

step (GreaterEquals (Num n1) (Num n2)) = if n1 >= n2 then BTrue else BFalse
step (GreaterEquals (Num n) e2) = GreaterEquals (Num n) (step e2)
step (GreaterEquals e1 e2) = GreaterEquals (step e1) e2

step (LeastEqual (Num n1) (Num n2)) = if n1 <= n2 then BTrue else BFalse
step (LeastEqual (Num n) e2) = LeastEqual (Num n) (step e2)
step (LeastEqual e1 e2) = LeastEqual (step e1) e2

step (Equals (Num n1) (Num n2)) = if n1 == n2 then BTrue else BFalse
step (Equals (Num n) e2) = Equals (Num n) (step e2)
step (Equals e1 e2) = Equals (step e1) e2

step (Different (Num n1) (Num n2)) = if n1 /= n2 then BTrue else BFalse
step (Different (Num n) e2) = Different (Num n) (step e2)
step (Different e1 e2) = Different (step e1) e2

step(Not BTrue) = BFalse
step(Not BFalse) = BTrue
step(Not e1) = Not (step e1)

-- Exibe o total de números após a execução do laço
step (For (Var v) (Num start) (Num end) body)
          | start > end = Num 0
          | otherwise   = Add (step innerFor) (subst v (Num start) body)
        where
          innerFor = For (Var v) (Num (start + 1)) (Num end) body

step (While (Num 0) _) = Num 0
step (While (Num n) e2) = step (For (Var "i") (Num 1) (Num n) e2)
step (While e1 e2) = While (step e1) e2

step (First (List (e:_))) = e
step (First e) = First (step e)

step (Second (List (_:se))) = List se
step (Second e) = Second (step e)

step e = error (show e)

eval :: Expr -> Expr
eval (List ls) = List (map eval ls)
eval e | isValue e = e
       | otherwise = eval (step e)