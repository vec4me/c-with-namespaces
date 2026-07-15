# C with Namespaces

## Motivation

I wanted something resembling C because, more often than not, you can find good
C programmers. That is less guaranteed with other languages, especially in a
startup where onboarding will eventually matter. However, plain C is personally
not readable enough to me because locality is, at worst, a choice, as opposed to
compiler-enforced. That makes encapsulation harder to reason about. With C++
namespaces, compliance is guaranteed.

I went through many languages like Nim, D, and Nelua, and while I liked most of
them, I realized there is more value in conventionality than I was initially
understanding. Being as close to a C standard as possible is much better than
making the language depend on some random compiler.

I explored deeply amongst the C and C++ languages how to have one type of file,
and literally only C++20 modules were the solution. They are not amazing, but
they are really the best thing we have, so each source file is a C++20 module.
No header file for every source file either, which was one of my other dislikes.
This essentially enforces what I consider a more legible version of C. Locality
is key.

Well Jeff, you're a hypocrite, because this still sounds like a random compiler.
The difference is that the tool doesn't actually compile anything: it is
validation. It removes the C++20 module and namespace surface, then checks the
remaining C.

## Furthermore

The validator requires supplying the whole set of code together, not individual
sources or modules one at a time. Imports and namespaces are not really
meaningful as one-off files, so the tool validates the connected set of files.
Sources may be supplied in any order; the validator derives their dependency
order from imports.

Modules do not prescribe namespace names or require a namespace at all. A module
may contain any number of named namespaces, and namespaces may be nested,
reopened, or written using compact nested syntax:

Namespace qualification is flattened by replacing each `::` with `__`.
Consequently, `company::service::status` is checked as
`company__service__status` in the lowered C. Whitespace and comments may appear
between module, import, export, and namespace tokens.

Here's an example usage:
```sh
c-with-namespaces check gun.ccm character.ccm deathmatch.ccm main.cc -- -std=c89 -Wall -Wextra -pedantic
```

## Rule of Thumb

As long as the code is C apart from the namespace-related syntax, it
is compliant.