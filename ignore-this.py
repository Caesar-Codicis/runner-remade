
import numpy as np
import sys

def TernaryToDecimal(the_vector):
    return sum([the_vector[i] * (3 ** (3 - i)) for i in range(4)])

def GenerateAll81Vectors():
    local_all_vectors = []
    for a in range(3):
        for b in range(3):
            for c in range(3):
                for d in range(3):
                    local_all_vectors.append([a,b,c,d])
    
    return np.asarray(local_all_vectors)


def PruneFutureChoices(subset_until_now):
    global viable_extensions_to_cap_set
    global no_longer_considered_vectors
    global amount_to_return_to_viable

    kMaxOfSubset = subset_until_now.shape[0]
    
    k = 0

    for w in range(kMaxOfSubset):
        bad_vector = -(subset_until_now[w] + subset_until_now[kMaxOfSubset-1]) % 3

        if (np.any(np.all(bad_vector == viable_extensions_to_cap_set, axis=1))):
            if (no_longer_considered_vectors.ndim == 1):
                no_longer_considered_vectors = np.vstack((no_longer_considered_vectors,bad_vector))

                viable_extensions_to_cap_set = np.delete(viable_extensions_to_cap_set, np.where(np.all(viable_extensions_to_cap_set == bad_vector, axis=1))[0],axis=0)
                no_longer_considered_vectors = np.reshape(no_longer_considered_vectors,(-1,4))
                k += 1
            elif not (np.any(np.all(bad_vector == no_longer_considered_vectors, axis=1))):
                viable_extensions_to_cap_set = np.delete(viable_extensions_to_cap_set, np.where(np.all(viable_extensions_to_cap_set == bad_vector, axis=1))[0],axis=0)
                no_longer_considered_vectors = np.vstack((no_longer_considered_vectors,bad_vector))
                k+= 1
                
    
    amount_to_return_to_viable.append(k)


def BacktrackingAlgorithm():
    global best_cap_set
    global length_of_best_cap_set

    global calculated_potential_cap_set
    global no_longer_considered_vectors
    global viable_extensions_to_cap_set

    global recursion_depth

    for j in range(viable_extensions_to_cap_set.shape[0]):
        if(viable_extensions_to_cap_set.size == 0):
            print(calculated_potential_cap_set)
            print("\n\n\n")
            if (calculated_potential_cap_set.shape[0] > length_of_best_cap_set):
                best_cap_set = calculated_potential_cap_set
                length_of_best_cap_set = calculated_potential_cap_set.shape[0]

            for X in range(amount_to_return_to_viable[-1]):
                viable_extensions_to_cap_set = np.vstack((viable_extensions_to_cap_set,no_longer_considered_vectors[-1]))
                no_longer_considered_vectors = np.delete(no_longer_considered_vectors, -1, axis=0)
            
            recursion_depth -= 1
            viable_extensions_to_cap_set[np.argsort([TernaryToDecimal(vec) for vec in viable_extensions_to_cap_set])]
            calculated_potential_cap_set = np.delete(calculated_potential_cap_set,-1,axis=0)
            return
            
        else:
            calculated_potential_cap_set = np.vstack((calculated_potential_cap_set,viable_extensions_to_cap_set[j]))
            PruneFutureChoices(calculated_potential_cap_set)
            recursion_depth += 1
            BacktrackingAlgorithm()
        
        


kAllVectors = GenerateAll81Vectors()
best_cap_set = []
length_of_best_cap_set = 16

kStartingVectors = np.array([[0,0,0,0],[0,0,0,1],[0,0,1,1],[0,0,1,2]], dtype=int)
calculated_potential_cap_set = []

viable_extensions_to_cap_set = np.empty([81,4],dtype=int)
no_longer_considered_vectors = np.empty([0,4],dtype=int)
amount_to_return_to_viable = []

recursion_depth = 0

for i in range(81):
    print("HI")
    calculated_potential_cap_set = kStartingVectors[i]
    viable_extensions_to_cap_set = np.delete(kAllVectors,np.where(np.all(kAllVectors == calculated_potential_cap_set,axis=1))[0],axis=0)
    no_longer_considered_vectors = calculated_potential_cap_set
    BacktrackingAlgorithm()