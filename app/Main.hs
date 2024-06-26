module Main where

import Parse (Token (..), value, values)
import Eval (EnvStack, eval)

import Data.HashMap.Strict (empty) 
import Text.Parsec (parse)
import System.IO
import System.Environment (getArgs)

import Data.Char (ord)

repl :: EnvStack -> IO ()
repl env = do
  putStr "> "
  hFlush stdout
  s <- getLine
  case parse value "" s of
    Left err -> print err >> repl env
    Right x -> do
      result <- eval env x
      case result of
        Right (x, new_env) -> print x >> repl new_env
        Left err -> print err >> repl env

evalLines :: String -> IO () 
evalLines content = do
  case parse values "" content of
    Left err -> print err
    Right xs -> evalValues xs $ pure . Right $ (Nil, [empty])
  where
    evalValues :: [Token] -> IO (Either String (Token, EnvStack)) -> IO ()
    evalValues [] acc = acc >> pure () 
    evalValues (x:xs) acc = do
      acc' <- acc
      case acc' of
        Left err -> putStr err
        Right (_, env) -> evalValues xs $ eval env x

main :: IO ()
main = do
  args <- getArgs
  case args of
    [path] -> do
      contents <- readFile path
      evalLines contents
    [] -> repl [empty]
    _ -> putStr "Could not resolve query"
