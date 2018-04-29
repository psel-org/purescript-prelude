module Data.Eq
  ( class Eq, eq, (==), notEq, (/=)
  , class Eq1, eq1, notEq1

  , class EqRecord
  , eqRecordImpl
  ) where

import Data.HeytingAlgebra ((&&))
import Data.Internal.Record (unsafeGet)
import Data.RowList (RLProxy(..))
import Data.Symbol (class IsSymbol, SProxy(..), reflectSymbol)
import Data.Unit (Unit)
import Data.Void (Void)
import Prim.Row as Row
import Prim.RowList as RL

-- | The `Eq` type class represents types which support decidable equality.
-- |
-- | `Eq` instances should satisfy the following laws:
-- |
-- | - Reflexivity: `x == x = true`
-- | - Symmetry: `x == y = y == x`
-- | - Transitivity: if `x == y` and `y == z` then `x == z`
-- |
-- | **Note:** The `Number` type is not an entirely law abiding member of this
-- | class due to the presence of `NaN`, since `NaN /= NaN`. Additionally,
-- | computing with `Number` can result in a loss of precision, so sometimes
-- | values that should be equivalent are not.
class Eq a where
  eq :: a -> a -> Boolean

infix 4 eq as ==

-- | `notEq` tests whether one value is _not equal_ to another. Shorthand for
-- | `not (eq x y)`.
notEq :: forall a. Eq a => a -> a -> Boolean
notEq x y = (x == y) == false

infix 4 notEq as /=

instance eqBoolean :: Eq Boolean where
  eq = refEq

instance eqInt :: Eq Int where
  eq = refEq

instance eqNumber :: Eq Number where
  eq = refEq

instance eqChar :: Eq Char where
  eq = refEq

instance eqString :: Eq String where
  eq = refEq

instance eqUnit :: Eq Unit where
  eq _ _ = true

instance eqVoid :: Eq Void where
  eq _ _ = true

instance eqArray :: Eq a => Eq (Array a) where
  eq = eqArrayImpl eq

foreign import refEq :: forall a. a -> a -> Boolean
foreign import eqArrayImpl :: forall a. (a -> a -> Boolean) -> Array a -> Array a -> Boolean

-- | The `Eq1` type class represents type constructors with decidable equality.
class Eq1 f where
  eq1 :: forall a. Eq a => f a -> f a -> Boolean

instance eq1Array :: Eq1 Array where
  eq1 = eq

notEq1 :: forall f a. Eq1 f => Eq a => f a -> f a -> Boolean
notEq1 x y = (x `eq1` y) == false

class EqRecord rowlist row focus | rowlist -> focus where
  eqRecordImpl :: RLProxy rowlist -> Record row -> Record row -> Boolean

instance eqRecordNil :: EqRecord RL.Nil row focus where
  eqRecordImpl _ _ _ = true

instance eqRecordCons
    :: ( EqRecord rowlistTail row subfocus
       , Row.Cons key focus rowTail row
       , IsSymbol key
       , Eq focus
       )
    => EqRecord (RL.Cons key focus rowlistTail) row focus where
  eqRecordImpl _ ra rb
    = unsafeGet' key ra == unsafeGet key rb
        && eqRecordImpl (RLProxy :: RLProxy rowlistTail) ra rb
    where key = reflectSymbol (SProxy :: SProxy key)
          unsafeGet' = unsafeGet :: String -> Record row -> focus

instance eqRecord
    :: ( RL.RowToList row list
       , EqRecord list row focus
       )
    => Eq (Record row) where
  eq = eqRecordImpl (RLProxy :: RLProxy list)
