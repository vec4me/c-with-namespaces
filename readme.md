# C with Namespaces

C with Namespaces is just a coding standard expressed in C++20, not a compiler,
so don't go running away just yet.

## Motivation

I wanted something resembling C because, more often than not, C programmers are
better than programmers who use other languages. This is especially important
in a startup, where conventionality, or the lack thereof, has a real cost.
In my opinion, C is objectively flawed in a way that makes programming harder
for any human: it lacks locality because it has no namespaces. Compensating for
that flaw requires additional explicitness in the form of prefixes everywhere,
which slows down code literacy and, in turn, slows down reasoning. Namespacing
therefore becomes a discipline, while C++ namespaces turn that discipline into
compiler-enforced locality.

I went through many languages like Nim, D, and Nelua, and while I liked most of
them, I realized there is more value in conventionality than I initially
understood. Code that lasts is also important to me, and that is more likely
with a language present throughout today's software than with some random C++
successor hidden like a needle in a haystack. Staying as close to standard C as
possible avoids making the language depend on an obscure compiler.

So, what's the solution?

It is not about finding the best successor to C/C++. It is about using what is
already at our disposal in the most effective way and, I kid you not, that means
C++20 modules. Remaining in the C ecosystem means no bindings, no foreign
runtime, and no separate ecosystem to maintain. C++20 modules also mean no
header file for every source file; we can use one type of file while enforcing
what I consider a more legible version of C. While C++20 modules are not
amazing, they are the best thing we have, which is why we use them.

## So, How Does It Work?

Because imports and namespace references can cross file boundaries, validating
a file in isolation would be incomplete. The tool therefore validates the
supplied source set together. Sources may be supplied in any order; the
validator derives their dependency order from imports.

Modules do not prescribe namespace names or require a namespace at all. A module
may contain any number of named namespaces, and namespaces may be nested,
reopened, or written using compact nested syntax:

Namespace qualification is flattened by replacing each `::` with `__`.
Consequently, `company::service::status` is checked as
`company__service__status` in the lowered C. Whitespace and comments may appear
between module, import, export, and namespace tokens.

## The Useful Part

Everything after `--` is passed directly to Clang, so an explicit option such
as `-std=c89` can enforce the C standard used for compliance. This effectively
lets a project use C++ namespace syntax while enforcing compliance with any C
standard supported by Clang.

Here's an example usage:

```sh
c-with-namespaces check gun.ccm character.ccm deathmatch.ccm main.cc -- -std=c89 -Wall -Wextra -pedantic
```

## Rule of Thumb

As long as the code is C apart from the namespace-related syntax, it
is compliant.
