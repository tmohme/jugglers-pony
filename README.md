# jugglers-pony
Slightly more sophisticated than the typical actor ping-pong example

Everyone who tries actor programming stumbles over the ubiquitous ping-pong example.

'jugglers' is similar but slightly more complex in order to take advantage of multiple cores:
Instead of only two players (actors) who transmit a ball (message) back and forth, we have several jugglers (actors) who throw several balls (messages) in a random fashion to each other.

The example is pretty much bare bones - no tooling, no build-system yet. Just grab yourself [the compiler from github](https://github.com/ponylang/ponyc#installation) and get going ;)  

The chosen language - pony - is according to [their website][ponylang.org] an '*open-source, object-oriented, actor-model, capabilities-secure, high performance programming language*'.

At least this very unscientific example is significantly faster than [its scala/akka counterpart . . .](https://github.com/tmohme/jugglers-akka)

[ponylang.org]: http://www.ponylang.org

*Pony* is very young and still immature and only for experimental use, but its __capability-secure__ness is very promising. A quote from their [tutorial:](https://tutorial.ponylang.org)

* It's type safe. Really type safe. There's a mathematical proof and everything.
* It's memory safe. Ok, this comes with type safe, but it's still interesting. There are no dangling pointers, no buffer overruns, heck, the language doesn't even have the concept of null!
* It's exception safe. There are no runtime exceptions. All exceptions have defined semantics, and they are always handled.
* It's data-race free. Pony doesn't have locks or atomic operations or anything like that. Instead, the type system ensures at compile time that your concurrent program can never have data races. So you can write highly concurrent code and never get it wrong.
* It's deadlock free. This one is easy, because Pony has no locks at all! So they definitely don't deadlock, because they don't exist.

Also it uses traits and algebraic data types instead of inheritance.
