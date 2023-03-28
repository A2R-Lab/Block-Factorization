def ndqlr_Solve(solver):
    """
    Returns 0 if the system was solved succeffuly.
    """

    #time the clock here for benchmarks omitted
    depth = solver.depth
    nhorizon = solver.nhorizon

    #Solving for independent diagonal block on the lowest level
    for k in range (nhorizon): #1 to N or 0 to N-1?
        ndlqr_SolveLeaf(solver,k)

    #Solving factorization
    for level in range (depth):
        numleaves = pow(2,depth - level -1) 

        #Calc Inner Products 
        cur_depth = depth-level 
        num_products = numleaves*cur_depth

        for i in range (num_products): 
            leaf = i/cur_depth
            upper_level = level+(i%cur_depth)
            index = solver.tree.ndlqr_GetIndexFromLeaf(leaf ,level) #or have this function outside of class BinaryTree?
            ndlqr_FactorInnerProduct(solver.data,solver.fact,index,level, upper_level)
             
        for leaf in range(numleaves):
            index = solver.tree.ndlqr_GetIndexFromLeaf(leaf,level)
            #get the Sbar Matrix calculated above
            #NdFactor* F
            F=ndlqr_GetNdFactor(solver.fact, index+1,level)
            sbar = F.lambda
            cholinfo = ndlqr_GetSFactorization (sovler.choldfacts,leaf,level)
            MatrixCholeskyFactorizeWithInfo(&Sbar,cholinfo)
            """
            Probably can substitute this whole piece with just Cholesky linalg?
            """

        #Solve with Cholesky factor for f
        upper_levels = cur_depth-1
        num_solves = numleaves*upper_levels
        for i in range (num_solves):
            leaf = i/upper_levels
            upper_level = level+1+(i%upper_levels)
            index = ndlqr_GetIndexFromLeaf(solver.tree,leaf,level)
            #ndlqr_GetSFactorization(solver->cholfacts, leaf, level, &cholinfo);
            #ndlqr_SolveCholeskyFactor(solver->fact, cholinfo, index, level, upper_level);
            """Rewrite it"""

        #Shur compliments - check for numpy library!
        num_factors = nhorizon * upper_levels
        for i in range(num_factors):
            k = i/upper_levels
            upper_level = level+1+(i%upper_levels)
            index = ndlqr_GetIndexAtLevel(solver.tree,k,level)
            calc_lambda = ndlqr_ShouldCalcLambda(solver.tree, index, k)
            ndlqr_UdpateShurFactor(solver.fact, solver.fact, index, k, level, upper_level,calc_lambda) 

        for level in range (depth):
            numleaves = PowerOfTwo(depth-level -1)

        #Calculate inner products with right-hand-side, with the factors computed above

        for leaf in range (numleaves):
            index = ndlqr_GetIndexFromLeaf(solver.tree,leaf,level)

            #Calculate z = d-F'b1-F2'b2
            ndlqr_FactorInnerProduct(solver.data, solver.soln, index,level,0)
        
        #Solve for separator variables with cached Cholesky decomp
        for leaf in range (numleaves):
            index = ndlqr_GetIndexFromLeaf(solver.tree,leaf,level)

        #Get the Sbar Matrix calculated above
        """WHAT IS Sbar Matrix??"""
        f = ndlqr_GetNdFactor(solver.fact,index+1,level)
        z = ndlqr_GetNdFactor(solver.soln,index+1,0)
        Sbar = F.lambda
        zy = z.lambda

        #Solve (S - C1'F1 - C2'F2)^{-1} (d - F1'b1 - F2'b2) -> Sbar \ z = zbar
        cholinfo = ndlqr_GetSFactorization(solver.cholfacts,leaf,level)
        MatrixCholeskyFactorizeWithInfo(cholinfo)

        #propogate information to solution vector
        #y = y- Fzbar
        for k in range (nhorizon):
            index = ndlqr_GetIndexAtLevel(solver.tree,k,level)
            calc_lambda=ndlqr_ShouldCalcLambda(solver.tree,index,k)
            ndlqr_UdpateShurFactor
    return 0 