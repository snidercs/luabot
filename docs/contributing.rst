Contributing
============

Thank you for your interest in contributing to LuaBot!

Development Setup
-----------------

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Run tests
6. Submit a pull request

Building
--------

See :doc:`installation` for build instructions.

Coding Standards
----------------

C++
~~~

* Use C++20 features where appropriate
* Follow ``snake_case`` for functions and variables
* Use ``PascalCase`` for classes
* Prefer RAII and smart pointers
* Always handle Lua errors with ``lua_pcall()``

Lua
~~~

* Use ``PascalCase`` for classes (e.g., ``TimedRobot``)
* Use ``camelCase`` for methods and variables
* Use ``---@class`` annotations for type hints
* Prefer single-quoted strings unless interpolation needed
* Private fields: prefix with underscore (``self._variablename``)

Testing
-------

Run the test suite::

    cd build
    ctest

Adding Tests
~~~~~~~~~~~~

* Create Lua unit tests in ``test/wpi/``
* Use ``luaunit.lua`` framework
* Test construction, methods, edge cases
* Add new tests to ``test/CMakeLists.txt``

Documentation
-------------

* Update documentation when adding features
* Use reStructuredText format
* Build docs locally to verify::

    cd docs
    sphinx-build -b html . _build

Submitting Pull Requests
-------------------------

1. Ensure all tests pass
2. Update documentation as needed
3. Follow the existing code style
4. Write clear commit messages
5. Reference any related issues

Getting Help
------------

* Open an issue for bugs or feature requests
* Join the discussion in existing issues
* Ask questions in pull request comments
