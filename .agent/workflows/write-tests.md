# Write Tests

Generate a comprehensive test suite for existing code.

## Steps

* Adopt the role defined in `ai-specs/.agents/testing-specialist.md`
* Analyze the target file or module provided
* Identify all code paths, edge cases, and error scenarios
* Write unit tests following Jest best practices and the AAA pattern (Arrange, Act, Assert)
* Include: happy path, boundary values, null/undefined inputs, error cases, and async behavior
* Mock all external dependencies (database, HTTP calls, file system) using Jest mocks
* Aim for 90%+ branch coverage on the target code
* Write integration tests if the code involves multiple layers working together
* Write Cypress E2E tests if the code includes a user-facing feature
* Verify tests are independent — each test cleans up its own state
* Run the test suite and confirm all tests pass
