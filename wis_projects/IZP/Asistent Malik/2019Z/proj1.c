/*
**      Title: IZP Project1
**      Start date: 2019-10-26
**      Last modification: 2019-11-10
**      Created by: Elena Carasec (xcaras00)
*/

#include <stdio.h>
#include <string.h>

typedef struct cont{
    char name[100];
    char number[100];
} contact;

// Finds and then returns a string that corresponds to the digit.
char *key_sign(char k){
    char *key[] = {"1", "2abc", "3def", "4ghi", "5jkl", "6mno", "7pqrs", "8tuv", "9wxyz", "0+"};
    int i = 0;
    int size = (sizeof(key)/sizeof(*key));

    while (i < size){
        if(strchr(key[i], k) != NULL){
            return key[i];
        }
        else{
            i++;
        }
    }
    return NULL;
}

// This function looks for coincidences in a contact. In case of success it returns 1.
int find_contact(char **argv, contact *c, int is_found){
    int n = 0;
    int i = 0;
    int m = 0;
    int k = 0;
    int arr[100]; // This array keeps positions of letters that should be capitalized.
    char *meaning = key_sign(argv[1][m]);
    char *c_data;

    // Deciding if it will search by name or by number.
    if(is_found == 0){
        c_data = c->name;
    }
    else if(is_found == 1){
        c_data = c->number;
    }

    // Cyklus searching coincidences.
    while(c_data[i] != '\0'){
        n = 0;
        while(meaning[n] != '\0'){
            if(c_data[i] == meaning[n]){
                m++;
                arr[k] = i;
                if(argv[1][m] != '\0'){
                    k++;

                    // Start checking if the next digit coincides with another sign.
                    meaning = key_sign(argv[1][m]);
                    n = 0;
                }
                else{
                    // Showing the found letters in capitals.
                    while(k >= 0){
                        if ((c_data[arr[k]] >= 'a') && (c_data[arr[k]] <= 'z')){
                            c_data[arr[k]] = c_data[arr[k]] - ('a' - 'A');
                        }
                        k--;
                    }

                    if(is_found == 0)
                        strcpy(c->name, c_data);
                    fprintf(stdout, "%s, %s", c->name, c->number);
                    return 1;
                }
                i++;
            }
            else{
                n++;
            }
        }
        i++;
    }
        
    return 0;
}



// All capital letters are turned into lowercase for easier comparison.
void capital_to_lowercase(contact *c){
    int i = 0;
    while (c->name[i] != '\0'){
        if ((c->name[i] >= 'A') && (c->name[i] <= 'Z')){
            c->name[i] = c->name[i] + ('a' - 'A');
        }
        i++;
    }
}

// We do not want to keep \n a \r signs in names.
void get_rid_of_nel_and_cr(contact *c){
    int i = 0;
    while(c->name[i] != '\0'){
        if((c->name[i] == '\n') || (c->name[i] == '\r')){
            c->name[i] = '\0';
        }    
        i++;
    }
}

void struct_creation(int argc, char **argv){
    int n = 0;
    int num_of_c = 100;
    contact c[num_of_c];
    
    // Getting data from the contact list.
    while((n < num_of_c) && (fgets(c[n].name, sizeof(c[n].name), stdin) != NULL)){
            fgets(c[n].number, sizeof(c[n].number), stdin);
            n++;
    }

    int i = 0;
    int name_found;
    int number_found;
    int is_pr = 0;  // Checks if at least one contact was printed.

    while(i < n){
        get_rid_of_nel_and_cr(&c[i]);
        capital_to_lowercase(&c[i]);
        if(argc == 1){
            fprintf(stdout, "%s, %s", c[i].name, c[i].number);
            is_pr = 1;
        }
        else{
            // If it finds the number in the field "name", there is no reason to look for it in the phone number again.
            // If we search by name, the last argument is 0, otherwise it is 1.
            name_found = find_contact(argv, &c[i], 0);
            if (name_found == 0){
                number_found = find_contact(argv, &c[i], 1);
            }
            is_pr = is_pr + name_found + number_found;
        }
        i++;
    }

    if (is_pr == 0){
        fprintf(stdout, "Not found.\n");
    }
}

int is_number(char **argv){
    int i = 0;
    while(argv[1][i] != '\0'){
        if((argv[1][i] < '0') || (argv[1][i] > '9')){
            return 1;
        }
        i++;
    }
    return 0;
}

int main(int argc, char **argv){
    if(argc == 1){
        struct_creation(argc, argv);
    }
    else if(argc == 2){
        // Checking if the argument contains only digits.
        int num = is_number(argv);
        if(num == 0){
            struct_creation(argc, argv);
        }
        else{
            fprintf(stderr, "Error. Please, enter a number.\n");
        }
    }
    else{
        fprintf(stderr, "Oops! Enter only one number.\n");
    }

    return 0;
}