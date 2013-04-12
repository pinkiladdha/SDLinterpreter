module Appearence.Camera where
import Text.ParserCombinators.Parsec
import Data.Char
--import Apperence.GLBaseTypes
import Graphics.UI.GLUT
import Graphics.Rendering.OpenGL
import Graphics.Rendering.OpenGL.GL.CoordTrans
import Data.List
--import GL
type Matrix1 = [[GLdouble]]
getColumn4 a b c d  = Vertex4 a b c d
parseInput :: [String] -> [(String,GLdouble,GLdouble,GLdouble)]
parseInput [] = []
parseInput (xs:xss) =if ((isInfixOf "location" xs) || (isInfixOf "look_at" xs ) || (isInfixOf "direction" xs ) )
                         then
                            let (l1 , interm) = splitAt (head(elemIndices '<' xs)) xs
                               in
                                 let (x1,y1,z1) = getLocation (fst (splitAt (head(elemIndices '>' xs)) interm))
                                   in do (l1 ,x1,y1,z1) :(parseInput xss) {-error ("location")--
                                         (parseInput xss) -}
                         else
                           if (isInfixOf "angle" xs)
                            then
                             let angle =  ( snd (splitAt (head (elemIndices ' ' (tail xs))) ( tail (xs) ) ) )
                               in ("angle",(read angle),0.0,0.0) :(parseInput xss) 
                             {- callFrustum angle
                                where angle = convertAngleType ( fst (splitAt (head (elemIndices ' ' (tail xs))) ( tail (xs) ) ) ) -}
                            else
                              if ( isInfixOf "up" xs)
                               then
                                 let (l1 , interm) = splitAt (head(elemIndices '<' xs)) xs
                                  in
                                   let (x1,y1,z1) = getLocation (fst (splitAt (head(elemIndices '>' xs)) interm))
                                     in do (l1 ,x1,y1,z1) :(parseInput xss) {-error("up")--
                                           (parseInput xss) -}
                               else
                                if ( isInfixOf "right" xs)
                                 then
                                   let (l1 , interm) = splitAt (head(elemIndices '<' xs)) xs
                                    in
                                     let (x1,y1,z1) = getLocation (fst (splitAt (head(elemIndices '>' xs)) interm))
                                       in do (l1 ,x1,y1,z1) :(parseInput xss) {-error("right")--
                                             (parseInput xss) -}
                                 
                                 else
                                      parseInput xss




callFrustum ( Vertex3 px py pz) (Vector3 ux uy uz) (Vector3 rx ry rz) (Vector3 dx dy dz) = do
		matrixMode $= Projection
		loadIdentity
		depthFunc $= Just Less
		sz<-get screenSize
                viewport   $= (Position 0 0, sz)
		let
			ul = sqrt (ux*ux + uy*uy + uz*uz)
			rl = sqrt (rx*rx + ry*ry + rz*rz)
			dl = sqrt (dx*dx + dy*dy + dz*dz)
		        near = 0.1
		        far = 100
                 	xview = realToFrac (rl / dl * near) *(-6.5)
			yview = realToFrac (ul / dl * near) * (3.5)
		
		frustum (-xview) xview (-yview) yview (realToFrac near) (realToFrac far)
		
		matrixMode $= (Modelview (-11))
		

msize :: Matrix1 -> Int
msize = length

mapMatrix :: (GLdouble -> GLdouble) -> Matrix1 -> Matrix1
mapMatrix f = map (map f)

coords :: Matrix1 -> [[(Int, Int)]]
coords = zipWith (map . (,)) [0..] . map (zipWith const [0..])

delmatrix :: Int -> Int -> Matrix1 -> Matrix1
delmatrix i j = dellist i . map (dellist j)
  where
    dellist i xs = take i xs ++ drop (i + 1) xs

determinant :: Matrix1 -> GLdouble
determinant m
    | msize m == 1 = head (head m)
    | otherwise    = sum $ zipWith addition [0..] m
  where
    addition i (x:_) =  x * cofactor i 0 m

cofactor :: Int -> Int -> Matrix1 -> GLdouble
cofactor i j m = ((-1.0) ** fromIntegral (i + j)) * determinant (delmatrix i j m)

cofactorM :: Matrix1 -> Matrix1
cofactorM m = map (map (\(i,j) -> cofactor j i m)) $ coords m

inverse :: Matrix1 -> Matrix1
inverse m = mapMatrix (* recip det) $ cofactorM m
  where
    det = determinant m






getScreenSize sz = 
                  case sz of
                    (Size w h) -> (w,h)
                 --   rest       -> error "not matching"



getHeight = do sz<-get screenSize
               case sz of
                (Size w h) -> return h
                

                




convertAngleType :: String -> GLdouble
convertAngleType xs = (read xs)
cameraFound xs = do
                  let location  = (findLoc (parseInput xs))
                      lookat    = findLookat (parseInput xs)
                      --direction = findDirection (parseInput xs)
                      direction = findUp (parseInput xs)
                    in setPointOfView location  lookat direction
                  callFrustum ( findLoc ( parseInput xs)) ( findUp ( parseInput xs)) (findRight ( parseInput xs)) (findDirection ( parseInput xs)) 
                --  callFrustum ( findAngle ( parseInput xs) )  ( calcMagnitude $ findUp ( parseInput xs) ) ( calcMagnitude $ findRight ( parseInput xs) )  ( calcMagnitude $ findDirection ( parseInput xs) ) 
                  --rotate (read "1.0" :: GLfloat) $ Vector3 1.0 1.2 1.3
                --  callFrustum ( calM $ findLoc ( parseInput xs)) (calcMagnitude $ findUp ( parseInput xs)) ( calcMagnitude $ findRight ( parseInput xs)) (calcMagnitude $ findDirection ( parseInput xs)) 
                  

findLoc res = let (a,x,y,z) = head ( filter (\(m,n,p,q) -> (isInfixOf "location" m ) ) res)
                in (Vertex3 (x) (y) (z))

findLookat res = let (a,x,y,z) = head ( filter (\(m,n,p,q) -> (isInfixOf "look_at" m ) ) res)
                  in (Vertex3 (x) y (z))

findDirection res = let (a,x,y,z) =head ( filter (\(m,n,p,q) -> (isInfixOf "direction" m ) ) res)
                     in (Vector3 (x) (y) (z))

findAngle res = let (a,x,y,z) =head ( filter (\(m,n,p,q) -> (isInfixOf "angle" m ) ) res)
                     in (x)

findUp res = let (a,x,y,z) =head ( filter (\(m,n,p,q) -> (isInfixOf "up" m ) ) res)
                     in (Vector3 x y (z))

findRight res = let (a,x,y,z) =head ( filter (\(m,n,p,q) -> (isInfixOf "right" m ) ) res)
                     in (Vector3 (x) (y) ((z)))

--calcMagnitude (Vertex3 x y z) = sqrt ( x*x+y*y+z*z)

calcMagnitude (Vector3 x y z) = sqrt ( x*x+y*y+z*z)
calM  (Vertex3 x y z) = sqrt ( x*x+y*y+z*z)


getLocation :: String -> (GLdouble,GLdouble,GLdouble)
getLocation xs = let (r,rs)   = getVal (tail xs)
                    in 
                      let (g, gs) = getVal rs
                        in 
                          let (b,bs) = getVal gs
                            in ((read r),(read g),(read b))

getVal :: String -> (String,String)
getVal (x:xs) = do
                  if ((x == ',') || (x == '>'))
                    then ([],xs)
                    else
                     if (isSpace x)
                      then (fst(getVal xs),snd(getVal xs))
                      else (x:fst(getVal xs),snd(getVal xs))

{-setPointOfView (Vertex3 lx ly lz) (Vertex3 lax lay laz) (Vector3 dx dy dz) = do 
                                                                                lookAt (Vertex3 (lx) (-ly) (-lz)) (Vertex3 (-lax) (-lay) (-laz)) (Vector3 (dx) (dy) (-dz))-}
setPointOfView location lookat direction = do lookAt (Vertex3 0.6 5.0 (-1.5)) (Vertex3 1.0 (0.95) 1.0) (Vector3 0.0 (-1.5) 0.0)

