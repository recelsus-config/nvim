#pragma once

#include <string>
#include <vector>

namespace lsp_test {

struct calculation {
  int left;
  int right;
  int result;
};

class math_service {
public:
  explicit math_service(std::string label);

  int add(int left, int right) const;
  int multiply(int left, int right) const;
  calculation summarize(int left, int right) const;
  const std::string& label() const;

private:
  std::string label_;
};

std::vector<calculation> build_examples(const math_service& service);

} // namespace lsp_test
