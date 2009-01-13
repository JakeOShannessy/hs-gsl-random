{-# LANGUAGE ForeignFunctionInterface #-}
-----------------------------------------------------------------------------
-- |
-- Module     : GSL.Random.Dist
-- Copyright  : Copyright (c) , Patrick Perry <patperry@stanford.edu>
-- License    : BSD3
-- Maintainer : Patrick Perry <patperry@stanford.edu>
-- Stability  : experimental
--
-- Random number distributions. Functions for generating random variates and
-- computing their probability distributions.
--

module GSL.Random.Dist (
    -- * The Gaussian Distribution
    -- ** General
    gaussianPdf,

    gaussianP,
    gaussianQ,
    gaussianPInv,
    gaussianQInv,

    getGaussian,
    getGaussianZiggurat,
    getGaussianRatioMethod,

    -- ** Unit Variance
    ugaussianPdf,

    ugaussianP,
    ugaussianQ,
    ugaussianPInv,
    ugaussianQInv,

    getUGaussian,
    getUGaussianRatioMethod,
    
    -- * The Flat (Uniform) Distribution
    flatPdf,

    flatP,
    flatQ,
    flatPInv,
    flatQInv,
    
    getFlat,

    -- * The Exponential Distribution

    exponentialPdf,

    exponentialP,
    exponentialQ,
    exponentialPInv,
    exponentialQInv,
    
    getExponential,

    -- * The Levy alpha-Stable Distributions
    getLevy,
    getLevySkew,
    
    -- * The Poisson Distribution
    poissonPdf,

    poissonP,
    poissonQ,

    getPoisson,
    
    ) where

import Control.Monad
import Foreign.C.Types      ( CUInt, CDouble )
import Foreign.ForeignPtr   ( withForeignPtr )
import Foreign.Ptr          ( Ptr )

import GSL.Random.Gen.Internal ( RNG(..) )

-- | @gaussianPdf x sigma@ computes the probabililty density p(x) for 
-- a Gaussian distribution with mean @0@ and standard deviation @sigma@.
gaussianPdf :: Double -> Double -> Double
gaussianPdf = liftDouble2 gsl_ran_gaussian_pdf

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_gaussian_pdf :: CDouble -> CDouble -> CDouble

-- | @gaussianP x sigma@ computes the cumulative distribution function P(x) for 
-- a Gaussian distribution with mean @0@ and standard deviation @sigma@.
gaussianP :: Double -> Double -> Double
gaussianP = liftDouble2 gsl_cdf_gaussian_P

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_gaussian_P :: CDouble -> CDouble -> CDouble

-- | @gaussianQ x sigma@ computes the cumulative distribution function Q(x) for 
-- a Gaussian distribution with mean @0@ and standard deviation @sigma@.
gaussianQ :: Double -> Double -> Double
gaussianQ = liftDouble2 gsl_cdf_gaussian_Q

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_gaussian_Q :: CDouble -> CDouble -> CDouble

-- | @gaussianPInv p sigma@ computes the inverse of the cumulative distribution 
-- function of a Gaussian distribution with mean @0@ and standard deviation
-- @sigma@. It returns @x@ such that @P(x) = p@.
gaussianPInv :: Double -> Double -> Double
gaussianPInv = liftDouble2 gsl_cdf_gaussian_Pinv

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_gaussian_Pinv :: CDouble -> CDouble -> CDouble

-- | @gaussianPInv q sigma@ computes the inverse of the cumulative distribution 
-- function of a Gaussian distribution with mean @0@ and standard deviation
-- @sigma@. It returns @x@ such that @Q(x) = q@.
gaussianQInv :: Double -> Double -> Double
gaussianQInv = liftDouble2 gsl_cdf_gaussian_Qinv

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_gaussian_Qinv :: CDouble -> CDouble -> CDouble

-- | @getGaussian r sigma@ gets a normal random variable with mean
-- @0@ and standard deviation @sigma@.  
-- This uses the Box-Mueller algorithm.
getGaussian :: RNG -> Double -> IO Double
getGaussian = getGaussianHelp gsl_ran_gaussian

-- | @getGaussianZiggurat r sigma@ gets a normal random variable with mean
-- @0@ and standard deviation @sigma@.  
-- This uses the Marsaglia-Tsang ziggurat algorithm.
getGaussianZiggurat :: RNG -> Double -> IO Double
getGaussianZiggurat = getGaussianHelp gsl_ran_gaussian_ziggurat

-- | @getGaussianRatioMethod r sigma@ gets a normal random variable with mean
-- @0@ and standard deviation @sigma@.  
-- This uses the Kinderman-Monahan-Leva ratio method.
getGaussianRatioMethod:: RNG -> Double -> IO Double
getGaussianRatioMethod = getGaussianHelp gsl_ran_gaussian_ratio_method

getGaussianHelp :: (Ptr () -> CDouble -> IO CDouble) 
                -> RNG -> Double -> IO Double
getGaussianHelp ran_gaussian (MkRNG fptr) sigma  =
    let sigma' = realToFrac sigma
    in withForeignPtr fptr $ \ptr -> do
        x <- ran_gaussian ptr sigma'
        return $ realToFrac x

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_gaussian :: Ptr () -> CDouble -> IO CDouble
foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_gaussian_ziggurat :: Ptr () -> CDouble -> IO CDouble
foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_gaussian_ratio_method :: Ptr () -> CDouble -> IO CDouble

-- | @ugaussianPdf x@ computes the probabililty density p(x) for 
-- a Gaussian distribution with mean @0@ and standard deviation @1@.
ugaussianPdf :: Double -> Double
ugaussianPdf = liftDouble gsl_ran_ugaussian_pdf

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_ugaussian_pdf :: CDouble -> CDouble

-- | @ugaussianP x@ computes the cumulative distribution function P(x) for 
-- a Gaussian distribution with mean @0@ and standard deviation @1@.
ugaussianP :: Double -> Double
ugaussianP = liftDouble gsl_cdf_ugaussian_P

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_ugaussian_P :: CDouble -> CDouble

-- | @ugaussianQ x@ computes the cumulative distribution function Q(x) for 
-- a Gaussian distribution with mean @0@ and standard deviation @1@.
ugaussianQ :: Double -> Double
ugaussianQ = liftDouble gsl_cdf_ugaussian_Q

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_ugaussian_Q :: CDouble -> CDouble

-- | @ugaussianPInv p@ computes the inverse of the cumulative distribution 
-- function of a Gaussian distribution with mean @0@ and standard deviation
-- @1@. It returns @x@ such that @P(x) = p@.
ugaussianPInv :: Double -> Double
ugaussianPInv = liftDouble gsl_cdf_ugaussian_Pinv

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_ugaussian_Pinv :: CDouble -> CDouble

-- | @ugaussianPInv q@ computes the inverse of the cumulative distribution 
-- function of a Gaussian distribution with mean @0@ and standard deviation
-- @1@. It returns @x@ such that @Q(x) = q@.
ugaussianQInv :: Double -> Double
ugaussianQInv = liftDouble gsl_cdf_ugaussian_Qinv

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_ugaussian_Qinv :: CDouble -> CDouble

-- | @getUGaussian r@ gets a normal random variable with mean
-- @0@ and standard deviation @1@.  
-- This uses the Box-Mueller algorithm.
getUGaussian :: RNG -> IO Double
getUGaussian = getUGaussianHelp gsl_ran_ugaussian

-- | @getUGaussianRatioMethod r@ gets a normal random variable with mean
-- @0@ and standard deviation @1@.  
-- This uses the Kinderman-Monahan-Leva ratio method.
getUGaussianRatioMethod:: RNG -> IO Double
getUGaussianRatioMethod = getUGaussianHelp gsl_ran_ugaussian_ratio_method
    
getUGaussianHelp :: (Ptr () -> IO CDouble) 
                -> RNG -> IO Double
getUGaussianHelp ran_ugaussian (MkRNG fptr)  =
    withForeignPtr fptr $ \ptr -> do
        x <- ran_ugaussian ptr
        return $ realToFrac x

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_ugaussian :: Ptr () -> IO CDouble
foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_ugaussian_ratio_method :: Ptr () -> IO CDouble

-- | @getExponential r mu@ gets a random exponential with mean @mu@.
getExponential :: RNG -> Double -> IO Double
getExponential (MkRNG f) mu = withForeignPtr f $ \p ->
    liftM realToFrac $ gsl_ran_exponential p (realToFrac mu)
    
foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_exponential :: Ptr () -> CDouble -> IO CDouble

-- | @exponentialPdf x mu@ computes the density at @x@ of an exponential
-- with mean @mu@.
exponentialPdf :: Double -> Double -> Double
exponentialPdf = liftDouble2 gsl_ran_exponential_pdf

foreign import ccall unsafe "gsl/gsl_randist.h" 
    gsl_ran_exponential_pdf :: CDouble -> CDouble -> CDouble

exponentialP :: Double -> Double -> Double
exponentialP = liftDouble2 gsl_cdf_exponential_P

foreign import ccall unsafe "gsl/gsl_randist.h" 
    gsl_cdf_exponential_P :: CDouble -> CDouble -> CDouble

exponentialQ :: Double -> Double -> Double
exponentialQ = liftDouble2 gsl_cdf_exponential_Q

foreign import ccall unsafe "gsl/gsl_randist.h" 
    gsl_cdf_exponential_Q :: CDouble -> CDouble -> CDouble

exponentialPInv :: Double -> Double -> Double
exponentialPInv = liftDouble2 gsl_cdf_exponential_Pinv

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_exponential_Pinv :: CDouble -> CDouble -> CDouble

exponentialQInv :: Double -> Double -> Double
exponentialQInv = liftDouble2 gsl_cdf_exponential_Qinv

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_exponential_Qinv :: CDouble -> CDouble -> CDouble

-- | @flatPdf x a b@ computes the probability density @p(x)@ at @x@ for
-- a uniform distribution from @a@ to @b@.
flatPdf :: Double -> Double -> Double -> Double
flatPdf = liftDouble3 gsl_ran_flat_pdf

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_flat_pdf :: CDouble -> CDouble -> CDouble -> CDouble

-- | @flatP x a b@ computes the cumulative distribution function @P(x)@.
flatP :: Double -> Double -> Double -> Double
flatP = liftDouble3 gsl_cdf_flat_P

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_flat_P :: CDouble -> CDouble -> CDouble -> CDouble

-- | @flatQ x a b@ computes the cumulative distribution function @Q(x)@.
flatQ :: Double -> Double -> Double -> Double
flatQ = liftDouble3 gsl_cdf_flat_Q

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_flat_Q :: CDouble -> CDouble -> CDouble -> CDouble

-- | @flatPInv p a b@ computes the inverse of the cumulative distribution
-- and returns @x@ so that function @P(x) = p@.
flatPInv :: Double -> Double -> Double -> Double
flatPInv = liftDouble3 gsl_cdf_flat_Pinv

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_flat_Pinv :: CDouble -> CDouble -> CDouble -> CDouble

-- | @flatQInv q a b@ computes the inverse of the cumulative distribution
-- and returns @x@ so that function @Q(x) = q@.
flatQInv :: Double -> Double -> Double -> Double
flatQInv = liftDouble3 gsl_cdf_flat_Qinv

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_flat_Qinv :: CDouble -> CDouble -> CDouble -> CDouble

-- | @getFlat r a b@ gets a value uniformly chosen in @[a,b)@.
getFlat :: RNG -> Double -> Double -> IO (Double)
getFlat (MkRNG fptr) a b  =
    let a' = realToFrac a
        b' = realToFrac b
    in withForeignPtr fptr $ \ptr -> do
            x <- gsl_ran_flat ptr a' b'
            return $ realToFrac x
        
foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_flat :: Ptr () -> CDouble -> CDouble -> IO CDouble

-- | @getLevy r c alpha@ gets a variate from the Levy symmetric stable
-- distribution with scale @c@ and exponent @alpha@.  The algorithm only
-- works for @0 <= alpha <= 2@.
getLevy :: RNG -> Double -> Double -> IO (Double)
getLevy (MkRNG f) c alpha =
    withForeignPtr f $ \p ->
        realToFrac `fmap` gsl_ran_levy p (realToFrac c) (realToFrac alpha)
        
foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_levy :: Ptr () -> CDouble -> CDouble -> IO CDouble

-- | @getLevySkew r c alpha beta@ gets a variate from the Levy skew stable
-- distribution with scale @c@, exponent @alpha@, and skewness parameter
-- @beta@.  The skewness parameter must lie in the range @[-1,1]@.  The
-- algorithm only works for @0 <= alpha <= 2@.
getLevySkew :: RNG -> Double -> Double -> Double -> IO (Double)
getLevySkew (MkRNG f) c alpha beta =
    withForeignPtr f $ \p ->
        realToFrac `fmap` gsl_ran_levy_skew p (realToFrac c) (realToFrac alpha) (realToFrac beta)
        
foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_levy_skew :: Ptr () -> CDouble -> CDouble -> CDouble -> IO CDouble

-- | @poissonPdf k mu@ evaluates the probability density @p(k)@ at @k@ for 
-- a Poisson distribution with mean @mu@.
poissonPdf :: Int -> Double -> Double
poissonPdf k = liftDouble $ gsl_ran_poisson_pdf (fromIntegral k)

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_poisson_pdf :: CUInt -> CDouble -> CDouble

-- | @poissonP k mu@ evaluates the cumulative distribution function @P(k)@ 
-- at @k@ for a Poisson distribution with mean @mu@.
poissonP :: Int -> Double -> Double
poissonP k = liftDouble $ gsl_cdf_poisson_P (fromIntegral k)

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_poisson_P :: CUInt -> CDouble -> CDouble

-- | @poissonQ k mu@ evaluates the cumulative distribution function @Q(k)@ 
-- at @k@ for a Poisson distribution with mean @mu@.
poissonQ :: Int -> Double -> Double
poissonQ k = liftDouble $ gsl_cdf_poisson_Q (fromIntegral k)

foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_cdf_poisson_Q :: CUInt -> CDouble -> CDouble

    
-- | @getPoisson r mu@ gets a poisson random variable with mean @mu@.
getPoisson :: RNG -> Double -> IO Int
getPoisson (MkRNG fptr) mu =
    let mu' = realToFrac mu
    in withForeignPtr fptr $ \ptr -> do
        x <- gsl_ran_poisson ptr mu' 
        return $ fromIntegral x
                    
foreign import ccall unsafe "gsl/gsl_randist.h"
    gsl_ran_poisson :: Ptr () -> CDouble -> IO CUInt



    
liftDouble :: (CDouble -> CDouble) 
           -> Double -> Double
liftDouble f x =
    realToFrac $ f (realToFrac x)

liftDouble2 :: (CDouble -> CDouble -> CDouble) 
           -> Double -> Double -> Double
liftDouble2 f x y =
    realToFrac $ f (realToFrac x) (realToFrac y)

liftDouble3 :: (CDouble -> CDouble -> CDouble -> CDouble) 
           -> Double -> Double -> Double -> Double
liftDouble3 f x y z =
    realToFrac $ f (realToFrac x) (realToFrac y) (realToFrac z)
