
import numpy as np

def generate_81_vectors():
    all_vectors = []
    for a in range(3):
        for b in range(3):
            for c in range(3):
                for d in range(3):
                    all_vectors.append([a,b,c,d])
    print("Successfully made " + str(len(all_vectors)) + " vectors")
    return all_vectors

def prune_for_vectors(subset, newest_addition):
    global potential_vectors
    global discarded_vectors
    global removed_at_step
    k = 0
    
    for i in range(len(subset)):
        bad_vector = (-(subset[i] + newest_addition)) % 3
        if np.any(np.all(bad_vector == potential_vectors, axis=1)):
            potential_vectors = np.delete(potential_vectors, bad_vector)
            discarded_vectors = np.append(discarded_vectors,bad_vector)
            k += 1
        else:
            pass
    
    removed_at_step.append(k)



current_best = 12
potential_vectors = generate_81_vectors()
discarded_vectors = []
removed_at_step = []

test_vector_1 = np.array([0,0,0,1])
test_vector_2 = np.array([0,1,1,1])
test_vector_3 = np.array([0,2,2,1])

current_subset = [test_vector_1]

prune_for_vectors(current_subset, test_vector_2)

print(discarded_vectors)
print(removed_at_step)