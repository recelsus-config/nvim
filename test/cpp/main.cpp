#include "math_service.hpp"

#include <iostream>

int main() {
  lsp_test::math_service service("sample-calculator");
  const auto examples = lsp_test::build_examples(service);

  for (const auto& example : examples) {
    std::cout << service.label() << ": " << example.left << " + "
              << example.right << " = " << example.result << '\n';
  }

  const int product = service.multiply(6, 7);
  std::cout << "product = " << product << '\n';
  return 0;
}
