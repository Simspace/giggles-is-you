{-# LANGUAGE PatternGuards, RecordWildCards, ViewPatterns #-}
module Main where

import Codec.Picture
import Control.Monad.Trans.Class
import Control.Monad.Trans.Except
import Graphics.Gloss
import Graphics.Gloss.Interface.IO.Interact
import Graphics.Gloss.Juicy

import Assets
import CharChart
import Draw
import Level
import Types
import World


main :: IO ()
main = do
  r <- runExceptT main'
  case r of
    Left err -> do
      error err
    Right () -> do
      pure ()


mustBeJust :: Maybe a -> M a
mustBeJust Nothing = ExceptT $ pure $ Left "Nothing encountered"
mustBeJust (Just a) = pure a

data Dir = N | E | W | S
  deriving (Eq, Show)

isDirKey :: SpecialKey -> Maybe Dir
isDirKey KeyRight = Just E
isDirKey KeyLeft  = Just W
isDirKey KeyUp    = Just N
isDirKey KeyDown  = Just S
isDirKey _        = Nothing

unitVector :: Num a => Dir -> (a, a)
unitVector N = (0,1)
unitVector E = (1,0)
unitVector W = (-1,0)
unitVector S = (0,-1)

lkp :: finiteMap -> Int -> Maybe Int
lkp = undefined

reactWorld :: Event -> World -> World
reactWorld (EventKey (SpecialKey (isDirKey -> Just dir)) Down _ _)
           w@(World {..})
  | Just playerPos <- findSprite whatIsYou level
  , let newPlayerPos = playerPos + unitVector dir
  , inBounds newPlayerPos level
  = w
  { level = moveSprite playerPos newPlayerPos level
  }
reactWorld _ w = w

main' :: M ()
main' = do
  r1 <- ExceptT $ readImage "assets/images/giggles.png"
  r2 <- ExceptT $ readImage "assets/images/sheets.png"
  giggles <- mustBeJust $ fromDynamicImage r1
  sheets  <- mustBeJust $ fromDynamicImage r2
  charChart <- lift loadCharChart
  let assets = Assets {..}
  let stepWorld :: Float -> World -> World
      stepWorld _dt world = world

  lift $ play (InWindow "Giggles is you" (200, 200) (-10, 10))
              white
              30
              (World level1 'B')
              (displayWorld assets)
              reactWorld
              stepWorld
