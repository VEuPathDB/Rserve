#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
Rcpp::NumericMatrix jsdphyloseq(Rcpp::NumericMatrix df) {
  int ncol = df.ncol();
  Rcpp::NumericMatrix result(ncol, ncol);
  for (int i = 0; i < ncol; i++) {
    for (int j=0; j<= i; j++) {
      Rcpp::NumericVector p = df(Rcpp::_, i);
      Rcpp::NumericVector q = df(Rcpp::_, j);
      Rcpp::NumericVector m = (p+q)/2;

      Rcpp::NumericVector t1 = p*Rcpp::log(p/m);
      t1[!Rcpp::is_finite(t1)] = 0;
      Rcpp::NumericVector t2 = q*Rcpp::log(q/m);
      t2[!Rcpp::is_finite(t2)] = 0;

      result(i,j) = Rcpp::sum(t1+t2)/2;
    }
  }
  return result;
}