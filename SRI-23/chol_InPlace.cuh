#include <cstdint>
#include <cooperative_groups.h>
namespace cgrps = cooperative_groups;
#include <cmath>

/**
 * @brief Perform a Cholesky decomposition in place.
 *
 * Performs a Cholesky decomposition on the square matrix @p s_A, storing the result in the
 * lower triangular portion of @p s_A. .
 *
 * @param T* s_A: a square symmetric matrix , row major
 * @param  int n: number of cols/rows in a square matrix s_A (n*n)
 *
 */

//FIRST VERSION
template <typename T> 
__device__ 
void chol_InPlace(int n, T *s_A) {
    for (uint32_t col = 0; col < n; col++) {
        if (threadIdx.x == 0){
            T sum = 0;
            T val = s_A[n*col+col]; //entry Ljj
            for(uint32_t col_l = 0 ; col_l < col; col_l++) {
                sum += pow(s_A[col*n+col_l],2);
            }
            s_A[col*n+col] = sqrt(val - sum);

        }
        __syncthreads(); //here we computed the diagonal entry of the column
        // compute the rest of the column
        for(uint32_t row = threadIdx.x + col +1; row < n; row += blockDim.x){
            T sum = 0;
            T val = s_A[row*n+col];
            for(uint32_t k = 0; k < col; k++) {
                sum += s_A[row*n+k]*s_A[col*n+k];
            }
            s_A[row*n+col] = (1.0/s_A[col*n+col])*(s_A[row*n+col]-sum);
        }
        __syncthreads();
    }
}

//cgrps version
 template <typename T> 
__device__ 
void chol_InPlace_r (uint32_t n,
                        T *s_A,
                        cgrps::thread_group g = cgrps::this_thread_block())
{
    for (uint32_t col = 0; col < n; col++) {
        if (g.thread_rank() == 0){
            T sum = 0;
            T val = s_A[n*col+col]; //entry Ljj
            for(uint32_t col_l = 0 ; col_l < col; col_l++) {
                sum += pow(s_A[col*n+col_l],2);
            }
            s_A[col*n+col] = sqrt(val - sum);

        }
        g.sync(); //here we computed the diagonal entry of the Matrix
        
        // compute the rest of the column
        for(uint32_t row = g.thread_rank()+ col +1; row < n; row += g.size()) 
        {
            T sum = 0;
            T val = s_A[row*n+col];
            for(uint32_t k = 0; k < col; k++) {
                sum += s_A[row*n+k]*s_A[col*n+k];
            }
            s_A[row*n+col] = (1.0/s_A[col*n+col])*(s_A[row*n+col]-sum);
        }
        g.sync();
    }
}

/**
 * @brief Perform a Cholesky decomposition in place.
 *
 * Performs a Cholesky decomposition on the square matrix @p s_A, storing the result in the
 * lower triangular portion of @p s_A. .
 *
 * @param T* s_A: a square symmetric matrix , column - major order.
 * @param  int n: number of cols/rows in a square matrix s_A (n*n)
 *
 */

//FINAL
template <typename T> 
__device__ 
void chol_InPlace_c (uint32_t n,
                        T *s_A,
                        cgrps::thread_group g = cgrps::this_thread_block())
{
    for (unsigned row = 0; row < n; row++) {
        if (g.thread_rank() == 0){
            T sum = 0;
            T val = s_A[n*row+row]; //entry Ljj
            for(uint32_t row_l = 0 ; row_l < row; row_l++) {
                sum += pow(s_A[row_l*n+row],2);
            }
            s_A[row*n+row] = sqrt(val - sum);

        }
        g.sync(); //here we computed the diagonal entry of the Matrix
        
        // compute the rest of the row  
        for(unsigned col = g.thread_rank()+ row +1; col < n; col += g.size()) 
        {
            T sum = 0;
            for(uint32_t k = 0; k < row; k++) {
                sum += s_A[k*n+col]*s_A[k*n+row];
            }
            s_A[row*n+col] = (1.0/s_A[row*n+row])*(s_A[row*n+col]-sum);
        }
        g.sync();
    }
}
