#include <iostream>
#include <chrono>
#include <string>
#include <vector>
#include <algorithm>
#include <list>
#include <stdlib.h>
using namespace std;

vector<vector<int>> kEverySingleVector;
vector<vector<int>> kSecondVectors;

vector<vector<int>> current_cap_set;
vector<vector<int>> potential_extensions_to_cap_set;
vector<vector<int>> disregarded_vectors_for_cap_set;
vector<int> amount_to_return;
vector<int> recursion_back_tracker = {0};

int record_size_of_cap_set = 16;
vector<vector<int>> record_cap_set;


void Prune(vector<vector<int>> considered_input_vector){
    int tracking = 0; // tracking how many vectors were eliminated
    for (int i = 0; i < considered_input_vector.size();i++) { // Check the newest addition against previous vectors
        vector<int> bad_vector;
        for (int j = 0; j<4; j++) { // Vectors cannot simply be added together so it needs to be constructed componentwise
            bad_vector.push_back(abs((-considered_input_vector[i][j]-considered_input_vector.back()[j]) % 3));
        };

        auto detection = find(potential_extensions_to_cap_set.begin(), potential_extensions_to_cap_set.end(), bad_vector);

        if (detection != potential_extensions_to_cap_set.end()) {
            // DEBUGGING cout << "REMoval time" << endl;
            int position_of_bad = distance(potential_extensions_to_cap_set.begin(),detection);

            disregarded_vectors_for_cap_set.push_back(potential_extensions_to_cap_set[position_of_bad]); // Add to disregarded
            potential_extensions_to_cap_set.erase(potential_extensions_to_cap_set.begin() + position_of_bad); // Remove from potential

            tracking++;

            // DEBUGGING cout << tracking << endl;
        };
        // DEBUGGING cout << "THis is also working" << endl ;

    };
    amount_to_return.push_back(tracking);
};

vector<vector<int>> GenerateAll81VectorsInF3() {
    vector<int> current_generated_vector;
    vector<vector<int>> output_all;
    for(int a = 0; a < 3; a++) {
        for(int b = 0; b<3; b++) {
            for(int c = 0; c<3; c++) {
                for(int d = 0; d<3; d++){
                    if(a+b+c+d == 0){
                        
                    } else {
                        current_generated_vector = {a,b,c,d};
                        output_all.push_back(current_generated_vector);
                    }
                }
            }
        }
    }
    return output_all;
};

void FindBestCapSet(int start_at) {
    Prune(current_cap_set);
    
    if(potential_extensions_to_cap_set.size() == 0){
        if (current_cap_set.size() > record_size_of_cap_set) {
            record_cap_set = current_cap_set;
            record_size_of_cap_set = record_cap_set.size();
        };

        for (int i = 0; i < amount_to_return.back(); i++) {
            potential_extensions_to_cap_set.push_back(disregarded_vectors_for_cap_set.back());
            disregarded_vectors_for_cap_set.pop_back();
        }
        
        amount_to_return.pop_back();
        current_cap_set.pop_back();
        std::sort(potential_extensions_to_cap_set.begin(), potential_extensions_to_cap_set.end(), [](vector<int> a, vector<int>b){
            return 27*a[0]+ 9*a[1]+ 3*a[2]+ a[3] < 27*b[0]+ 9*b[1]+ 3*b[2]+ b[3];
        });
        
        recursion_back_tracker.pop_back();
        recursion_back_tracker[recursion_back_tracker.size()-1] += 1;
        return;
    } else {
        current_cap_set.push_back(potential_extensions_to_cap_set[start_at]);
        recursion_back_tracker.push_back(0);
        FindBestCapSet(0);
    };

    int w = recursion_back_tracker.back();

    // DEBUGGING cout << "Unraveled" << endl;
    for (w; w < potential_extensions_to_cap_set.size(); w++) {
        FindBestCapSet(w);
    };

};


int main() {
    kEverySingleVector = GenerateAll81VectorsInF3();
    kSecondVectors = {{0,0,0,1}, {0,0,1,2}, {0,0,1,1}, {0,1,1,2}, {0,1,1,1}, {1,1,2,2}, {1,1,1,2}, {1,1,1,1}};
    
    potential_extensions_to_cap_set = kEverySingleVector;
    current_cap_set = {{0,0,0,0}};

    current_cap_set.push_back(kSecondVectors[0]);
    
    for (int i = 0; i<8; i++) {
        current_cap_set = {{0,0,0,0},kSecondVectors[i]};

        auto start = chrono::high_resolution_clock::now();
        FindBestCapSet(0);
        auto finish = chrono::high_resolution_clock::now();

        auto duration = chrono::duration_cast<chrono::microseconds>(finish-start);
        cout << endl << record_size_of_cap_set << " also note that it took " << duration.count() << endl;
    };


    // auto start = chrono::high_resolution_clock::now();
    // auto finish = chrono::high_resolution_clock::now();

    // auto duration = chrono::duration_cast<chrono::microseconds>(finish-start);
    // cout << endl << endl << duration.count() << endl;

    // SimpleRecursiveFunction(0);


    return 0;
}