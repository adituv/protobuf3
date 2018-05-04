{-# LANGUAGE OverloadedStrings #-}
module Data.Protobuf.CodeGenSpec(spec) where

import Test.Hspec

import Data.Protobuf.CodeGen


import Data.Either(isLeft)
import Data.Function((&))
import qualified Data.Text.Lazy as Text.Lazy
import Data.Tree.ScopeTree(ScopeTree)
import qualified Data.Tree.ScopeTree as ScopeTree

type LazyText = Text.Lazy.Text

spec :: Spec
spec =
  describe "Code generation" $ do
    nameResolveTests
    shouldPassTests
    shouldFailTests

sampleScopeTree :: ScopeTree LazyText
sampleScopeTree =
  ScopeTree.empty
    & ScopeTree.insert ["Some", "Scope", "Message", "Inner"]
    & ScopeTree.insert ["Some", "Scope", "Sibling"]
    & ScopeTree.insert ["Some", "Scope", "Sibling", "Cousin"]
    & ScopeTree.insert ["Some", "Scope", "Duplicate"]
    & ScopeTree.insert ["Some", "Scope", "Message", "Duplicate"]
    & ScopeTree.insert ["Some", "Scope", "Message", "Scope", "Duplicate"]

sampleCurrentScope :: [LazyText]
sampleCurrentScope = ["Some", "Scope", "Message"]

nameResolveTests :: Spec
nameResolveTests =
  describe "Name resolution" $ do
    it "does not resolve a name with no names in scope" $
      isLeft $
        resolveName
          sampleCurrentScope
          ScopeTree.empty
          "Inner"
    it "correctly resolves an unqualified name defined in the same scope" $
      Right ["Some", "Scope", "Message", "Inner"] ==
        resolveName
          sampleCurrentScope
          sampleScopeTree
          "Inner"
    it "does not resolve an unqualified name that is undefined" $
      isLeft $
        resolveName
          sampleCurrentScope
          sampleScopeTree
          "Missing"
    it "correctly resolves an unqualified name defined in an outer scope" $
      Right ["Some","Scope","Sibling"] ==
        resolveName
          sampleCurrentScope
          sampleScopeTree
          "Sibling"
    it "does not resolve an unqualified name defined in a sibling scope" $
      isLeft $
        resolveName
          sampleCurrentScope
          sampleScopeTree
          "Cousin"
    it "correct resolves a qualified name defined in the same scope" $
      Right ["Some","Scope","Message", "Inner"] ==
        resolveName
          sampleCurrentScope
          sampleScopeTree
          "Message.Inner"
    it "correctly resolves a qualified name defined in an outer scope" $
      Right ["Some", "Scope", "Sibling"] ==
        resolveName
          sampleCurrentScope
          sampleScopeTree
          "Some.Scope.Sibling"
    it "correctly resolves a qualified name defined in a sibling scope" $
      Right ["Some","Scope","Sibling","Cousin"] ==
        resolveName
          sampleCurrentScope
          sampleScopeTree
          "Sibling.Cousin"
    it "correctly resolves an unqualified duplicate name" $
      Right ["Some", "Scope", "Message", "Duplicate"] ==
        resolveName
          sampleCurrentScope
          sampleScopeTree
          "Duplicate"
    it "correctly resolves an unqualified name from outer scope" $
      Right ["Some", "Scope", "Message", "Inner"] ==
        resolveName
          sampleCurrentScope
          sampleScopeTree
          ".Inner"
    it "correctly resolves an unqualified duplicate name from outer scope" $
      Right ["Some", "Scope", "Duplicate"] ==
        resolveName
          sampleCurrentScope
          sampleScopeTree
          ".Duplicate"
    it "correctly resolves a qualified name from outer scope" $
      Right ["Some", "Scope", "Message"] ==
        resolveName
          ["Some", "Scope", "Message", "Scope"]
          sampleScopeTree
          ".Scope.Message"
    it "correctly resolves a qualified duplicate name from outer scope" $
      Right ["Some", "Scope", "Duplicate"] ==
        resolveName
          ["Some", "Scope", "Message", "Scope"]
          sampleScopeTree
          ".Scope.Duplicate"

shouldPassTests :: Spec
shouldPassTests = pure ()

shouldFailTests :: Spec
shouldFailTests = pure ()
