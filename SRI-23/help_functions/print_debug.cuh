#pragma once
#include <stdint.h>
#include <cuda_runtime.h>
#include <cmath>
#include <cooperative_groups.h>

/** @brief Prints the desired matrix in row-column order.
 * @param T *matrix - pointer to the stored matrix
 * @param uint32 rows - number of rows in matrix
 * @param uint32 columns - number of columns
 * */
template <typename T>
__host__ __device__ void printMatrix(T *matrix, uint32_t rows, uint32_t cols)
{
    for (unsigned i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            printf("%f  ", matrix[j * rows + i]);
        }
        printf("\n");
    }
}

template <typename T>
__host__ __device__ void print_KKT(T *F_lambda, T *F_state, T *F_input, T *d,
                                   T *q_r, uint32_t nhorizon, uint32_t depth, uint32_t nstates, uint32_t ninputs)
{
    uint32_t states_sq = nstates * nstates;
    uint32_t inp_states = nstates * ninputs;
    for (uint32_t ind = 0; ind < nhorizon * depth; ind++)
    {
        if (ind % nhorizon == 0)
        {
            printf("\nLEVEL %d\n", ind / nhorizon);
        }
        printf("\nF_lambda #%d: \n", ind);
        printMatrix(F_lambda + (ind * states_sq), nstates, nstates);

        printf("\nF_state #%d: \n", ind);
        printMatrix(F_state + (ind * states_sq), nstates, nstates);

        printf("\nF_input #%d: \n", ind);
        printMatrix(F_input + ind * inp_states, ninputs, nstates);
    }
    for (unsigned i = 0; i < nhorizon; i++)
    {
        printf("\nd%d: \n", i);
        printMatrix(d + i * nstates, 1, nstates);

        printf("\nq%d: \n", i);
        printMatrix(q_r + (i * (ninputs + nstates)), 1, nstates);

        printf("\nr%d: \n", i);
        printMatrix(q_r + (i * (ninputs + nstates) + nstates), 1, ninputs);
    }
}

template <typename T>
__host__ __device__ void print_ram_shared(T *s_F_lambda, T *s_F_state, T *s_F_input, T *s_d, T *s_q_r, 
                                    T *d_F_lambda, T *d_F_state, T *d_F_input, T *d_d, T *d_q_r, 
                                   uint32_t nhorizon, uint32_t depth, uint32_t nstates, uint32_t ninputs)
{
    uint32_t states_sq = nstates * nstates;
    uint32_t inp_states = nstates * ninputs;
    for (uint32_t ind = 0; ind < nhorizon * depth; ind++)
    {
        if (ind % nhorizon == 0)
        {
            printf("\nLEVEL %d\n", ind / nhorizon);
        }
        printf("\ns_F_lambda #%d: \n", ind);
        printMatrix(s_F_lambda + (ind * states_sq), nstates, nstates);
        printf("\nd_F_lambda #%d: \n", ind);
        printMatrix(d_F_lambda + (ind * states_sq), nstates, nstates);

        printf("\ns_F_state #%d: \n", ind);
        printMatrix(s_F_state + (ind * states_sq), nstates, nstates);
        printf("\nd_F_state #%d: \n", ind);
        printMatrix(d_F_state + (ind * states_sq), nstates, nstates);

        printf("\ns_F_input #%d: \n", ind);
        printMatrix(s_F_input + ind * inp_states, ninputs, nstates);
        printf("\nd_F_input #%d: \n", ind);
        printMatrix(d_F_input + ind * inp_states, ninputs, nstates);
    }
    for (unsigned i = 0; i < nhorizon; i++)
    {
        printf("\ns_d%d: \n", i);
        printMatrix(s_d + i * nstates, 1, nstates);
        printf("\nd_d%d: \n", i);
        printMatrix(d_d + i * nstates, 1, nstates);

        printf("\ns_q%d: \n", i);
        printMatrix(s_q_r + (i * (ninputs + nstates)), 1, nstates);
        printf("\nd_q%d: \n", i);
        printMatrix(d_q_r + (i * (ninputs + nstates)), 1, nstates);

        printf("\ns_r%d: \n", i);
        printMatrix(s_q_r + (i * (ninputs + nstates) + nstates), 1, ninputs);
        printf("\nd_r%d: \n", i);
        printMatrix(d_q_r + (i * (ninputs + nstates) + nstates), 1, ninputs);
    }
}
template <typename T>
__host__ __device__ void print_step_matrix(uint32_t ind, T *F_lambda, T *F_state, T *F_input,  uint32_t nstates, uint32_t ninputs)
{
    uint32_t states_sq = nstates * nstates;
    uint32_t inp_states = nstates * ninputs;
    printf("\nF_lambda #%d: \n", ind);
    printMatrix(F_lambda + (ind * states_sq), nstates, nstates);

    printf("\nF_state #%d: \n", ind);
    printMatrix(F_state + (ind * states_sq), nstates, nstates);

    printf("\nF_input #%d: \n", ind);
    printMatrix(F_input + ind * inp_states, ninputs, nstates);
}

template <typename T>
__host__ __device__ void print_step(uint32_t ind, T *F_lambda, T *F_state, T *F_input, T *d,
                                    T *q_r, uint32_t nhorizon, uint32_t depth, uint32_t nstates, uint32_t ninputs)
{
    uint32_t states_sq = nstates * nstates;
    uint32_t inp_states = nstates * ninputs;
    printf("\nF_lambda #%d: \n", ind);
    printMatrix(F_lambda + (ind * states_sq), nstates, nstates);

    printf("\nF_state #%d: \n", ind);
    printMatrix(F_state + (ind * states_sq), nstates, nstates);

    printf("\nF_input #%d: \n", ind);
    printMatrix(F_input + ind * inp_states, ninputs, nstates);
    printf("\nd%d: \n", ind);
    printMatrix(d + ind * nstates, 1, nstates);

    printf("\nq%d: \n", ind);
    printMatrix(q_r + (ind * (ninputs + nstates)), 1, nstates);

    printf("\nr%d: \n", ind);
    printMatrix(q_r + (ind * (ninputs + nstates) + nstates), 1, ninputs);
}