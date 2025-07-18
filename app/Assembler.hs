module Assembler where

data Asm = Mov String String | Call String |
           Label String | Ret | Sub String String |
           Pop String | Push String | Inline String

-- Super big order of complexity find a nicer solution
movFolding :: [Asm] -> [Asm] -> [Asm]
movFolding (m1@(Mov y1 x):m2@(Mov z y2):xs) acc =
  if y1 == y2 then
   movFolding (Mov z x:xs) acc
  else movFolding (m2:xs) $ acc ++ [m1]
movFolding (x:xs) acc = movFolding xs $ acc ++ [x]
movFolding [] acc = acc

generateAsm :: [Asm] -> String
generateAsm xs = "global _start\nsection .text" ++ concatMap show xs 

instance Show Asm where
  show (Mov x y) = "\n\tmov " ++ x ++ ", " ++ y
  show (Call label) = "\n\tcall " ++ label
  show (Label label) = "\n" ++ label ++ ":"
  show Ret = "\n\tret"
  show (Pop x) = "\n\tpop " ++ x
  show (Push x) = "\n\tpush " ++ x
  show (Sub x y) = "\n\tsub " ++ x ++ ", " ++ y
  show (Inline x) = "\n\t" ++ x
  
