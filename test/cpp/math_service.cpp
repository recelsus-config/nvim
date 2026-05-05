#include "math_service.hpp"

#include <utility>

namespace lsp_test {

math_service::math_service(std::string label) : label_(std::move(label)) {}

int math_service::add(int left, int right) const {
  return left + right;
}

int math_service::multiply(int left, int right) const {
  return left * right;
}

calculation math_service::summarize(int left, int right) const {
  return calculation{
      .left = left,
      .right = right,
      .result = add(left, right),
  };
}

const std::string& math_service::label() const {
  return label_;
}

std::vector<calculation> build_examples(const math_service& service) {
  return {
      service.summarize(1, 2),
      service.summarize(3, 5),
      service.summarize(8, 13),
  };
}

} // namespace lsp_test
