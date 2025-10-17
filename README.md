# gmentropylogit

### Generalized Maximum Entropy Estimation for Discrete Choice Models in Stata

`gmentropylogit` implements the **Generalized Maximum Entropy (GME)** estimation method for discrete choice models, following the formulation of Golan, Judge, and Perloff (1996).  
This Stata command provides an alternative to conventional logit and probit estimators, offering robust performance when traditional assumptions fail—particularly with **small samples**, **highly correlated covariates**, or **ill-conditioned matrices**.

---

## 📘 Background

The **maximum entropy (ME)** principle selects the probability distribution with minimal information content given the data constraints, making it the most noncommittal choice among multinomial distributions.  
The **generalized maximum entropy (GME)** approach extends ME by explicitly incorporating *noise components* within the information constraints, improving estimation performance in finite samples.

GME combines desirable properties of both information-theoretic and maximum-likelihood estimators:

- ✅ More efficient under small samples  
- ✅ Avoids strong parametric assumptions  
- ✅ Handles multicollinearity gracefully  
- ✅ Works well when the design matrix is ill-conditioned  
- ✅ Produces interpretable coefficients and marginal effects  

---

## ⚙️ Installation

From within Stata:

```stata
github install pcorralrodas/gmentropylogit
```

```stata
net install gmentropylogit, from("https://raw.githubusercontent.com/paulcorral/gmentropylogit/main/")
```

Or manually clone the repository and place the files in your Stata `PERSONAL` or `PLUS` directory.

```bash
git clone https://github.com/paulcorral/gmentropylogit.git
```

---

## 🧩 Syntax

```stata
gmentropylogit depvar [indepvars] [if] [in] [, mfx generate(varname)]
```

### Options
- `mfx` — Displays marginal effects (`dF/dx`) instead of coefficients.  
  Handles both continuous and dummy variables appropriately.  
- `generate(varname)` — Creates a new variable with the predicted probabilities from the fitted model.

---

## 💡 Example

```stata
. sysuse auto, clear
. gmentropylogit foreign price mpg weight trunk
```

Output:

```
Generalized Maximum Entropy (Logit)
Number of obs = 74
Degrees of freedom = 4
Entropy for probs. = 24.4
Normalized entropy = 0.4750
Ent. ratio stat. = 53.9
P Val for LR = 0.0000
Pseudo R2 = 0.5250
```

### Marginal Effects

```stata
. gmentropylogit foreign price mpg weight trunk, mfx
```

### Predicted Probabilities

```stata
. gmentropylogit foreign price mpg weight trunk, generate(p_foreign)
```

---

## 📊 Output Statistics

In addition to coefficient estimates and marginal effects, the command reports **information-theoretic diagnostics**:

| Statistic | Description |
|------------|--------------|
| **Entropy for probs.** | Shannon entropy of estimated probabilities |
| **Normalized entropy (Ŝ)** | Proportion of remaining uncertainty in the model |
| **Entropy ratio statistic (W)** | Analogous to likelihood-ratio test |
| **Pseudo R² (Î)** | Information index: \( I(p̂) = 1 - S(p̂) \) |
| **Percent correctly predicted** | Classification accuracy for binary outcomes |

---

## 🧠 Methodology

The estimator maximizes the joint entropy of probabilities \(p\) and noise weights \(w\):

\[
\max_{p, w} \; H(p, w) = -p'\ln p - w'\ln w
\]

subject to:

\[
(I_J \otimes X')y = (I_J \otimes X')(p + wv)
\]

and normalization constraints:

\[
\sum_j p_{ij} = 1, \quad \sum_h w_{ijh} = 1
\]

The resulting dual formulation:

\[
M(\lambda_j) = y'(I_J \otimes X)\lambda + \sum_i \ln \Omega_i(\lambda_j) + \sum_i \sum_j \ln \Psi_{ij}(\lambda_j)
\]

is optimized via Stata’s `optimize()` function in Mata.

---

## 📈 References

- Golan, A., G. Judge, and J. Perloff (1996). *A Maximum Entropy Approach to Recovering Information from Multinomial Response Data*. **Journal of the American Statistical Association**, 91(434), 841–853.  
- Golan, A., G. Judge, and D. Miller (1996). *Maximum Entropy Econometrics: Robust Estimation with Limited Data.* Wiley.  
- Soofi, E. S. (1992). *A Generalizable Formulation of Conditional Logit with Diagnostics.* **JASA**, 87(420), 812–816.  
- Corral, P., & Terbish, M. (2015). *Generalized Maximum Entropy Estimation of Discrete Choice Models.* **Stata Journal**, 15(2), 512–522.

---

## 👩‍💻 Authors

**Paul Corral**  
Senior Economist, World Bank  
✉️ [paulcorral@gmail.com](mailto:paulcorral@gmail.com)

**Mungo Terbish**  
Economist, American University  
✉️ [mungunsuvd@gmail.com](mailto:mungunsuvd@gmail.com)

---

## 📄 License

This software is distributed under the **MIT License**.  
See [`LICENSE`](LICENSE) for details.
