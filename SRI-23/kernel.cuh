/*
1. Launch Kernel with grid_dim = blocks
2. initalize shared_memory
3. move ram to shared : NEED block/grid.sync?
4. After solve leaf need to copy to RAM :
    F_state,F_input[timestep n in  level[n]]
    F_state[n+1 in  level[n] ]
    AND q[n] and r[n]
5. Copy Back to Shared
6. For



for debugging

HAVE BETTER DATA STRUCTURE!
different arrays for q/r/Q/R/A/B?? An array for a block?
 if (DEBUG)
    {
      if (block_id == 0 && thread_id == 0)
      {
        printf("CHECKING DATA BEFORE SOLVE LEAF");
        for (uint32_t ind = 0; ind < nhorizon * depth; ind++)
        {
          if (ind % nhorizon == 0)
          {
            printf("\nLEVEL %d\n", ind / nhorizon);
          }
          printf("\nF_lambda #%d: \n", ind);
          printMatrix(s_F_lambda + (ind * states_sq), nstates, nstates);

          printf("\nF_state #%d: \n", ind);
          printMatrix(s_F_state + (ind * states_sq), nstates, nstates);

          printf("\nF_input #%d: \n", ind);
          printMatrix(s_F_input + ind * inp_states, ninputs, nstates);
        }
        for (unsigned i = 0; i < nhorizon; i++)
        {
          printf("\nd%d: \n", i);
          printMatrix(d_d + i * nstates, 1, nstates);

          printf("\nq%d: \n", i);
          printMatrix(d_q_r + (i * (ninputs + nstates)), 1, nstates);

          printf("\nr%d: \n", i);
          printMatrix(d_q_r + (i * (ninputs + nstates) + nstates), 1, ninputs);
        }
      }
    }
*/