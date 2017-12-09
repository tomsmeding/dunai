-- | This module combines the wrapping and running functions
--   for the 'Reader', 'Writer' and 'State' monad layers in a single layer.
module Control.Monad.Trans.MSF.RWS
  ( module Control.Monad.Trans.MSF.RWS
  , module Control.Monad.Trans.RWS.Strict
  ) where

-- External
import Control.Monad.Trans.RWS.Strict
  hiding (liftCallCC, liftCatch) -- Avoid conflicting exports
import Data.Monoid
import Data.Functor ((<$>))

-- Internal
import Data.MonadicStreamFunction

-- * 'RWS' (Reader-Writer-State) monad


-- | Wrap an 'MSF' with explicit state variables in 'RWST' monad.
rwsS :: (Functor m, Monad m, Monoid w)
     => MSF m (r, s, a) (w, s, b)
     -> MSF (RWST r w s m) a b
rwsS = hoistGen $ \f a -> RWST $ \r s -> (\((w, s', b), c) -> ((b, c), s', w))
   <$> f (r, s, a)

-- | Run the 'RWST' layer by making the state variables explicit.
runRWSS :: (Functor m, Monad m, Monoid w)
        => MSF (RWST r w s m) a b
        -> MSF m (r, s, a) (w, s, b)
runRWSS = hoistGen $ \f (r, s, a) -> (\((b, c), s', w) -> ((w, s', b), c))
      <$> runRWST (f a) r s
