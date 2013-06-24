{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}

module Receiver where

import Control.Monad.IO.Class (liftIO)
import qualified Data.ByteString.Lazy as B
import Data.Aeson
import Data.String
import Network.HTTP.Types
import System.Cmd
import Web.Scotty

import Conf
import Message

receiver :: [Conf] -> ScottyM ()
receiver confs = do
    get "/" $ html "<h1>Post Receive Server</h1>"
    mapM_ receiver' confs
  where
    receiver' (Conf name paths) = do
        let route = fromString $ '/' : name
        post route $ do
            str <- body
            case dec str of
                Left msg -> liftIO $ putStrLn msg
                Right msg -> do
                    liftIO $ print msg
                    liftIO $ mapM_ system paths

dec :: B.ByteString -> Either String Message
dec = eitherDecode . B.drop 8 . B.fromStrict . urlDecode False . B.toStrict
