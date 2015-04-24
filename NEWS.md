JuMPChance release notes
========================

Unreleased
----------

  * ``solvechance`` method renamed to ``solve``
  * The meaning of ``with_probability`` **has changed**. Constraints must now hold with the given probability or greater, which is tractable for 1/2 or greater. A deprecation warning is in place when a small value is provided.

Version 0.1.1 (January 10, 2015)
--------------------------------

  * Clarify and tidy up support for integer variables.

Version 0.1.0 (January 4, 2015)
-------------------------------

  * Initial release