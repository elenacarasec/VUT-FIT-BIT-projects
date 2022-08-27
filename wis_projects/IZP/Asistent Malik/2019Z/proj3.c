/*
**      Title:              IZP Project3
**      Start date:         2019-12-02
**      Last modification:  2019-12-11
**      Created by:         Elena Carasec (xcaras00)
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#define max_strlen 100
#define invalid_start 3

enum borders {no_border, left_border, right_border, top_bottom_border = 4};
enum rules {left_hand, right_hand};

typedef struct {
    int rows;
    int cols;
    unsigned char *cells;
} Map;

//Checking if there is a border where we ask
bool isborder(Map *map, int r, int c, int border){
    int left, right, top_bottom;
    int current_cell = (r - 1) * map->cols + c - 1;

    top_bottom = (map->cells[current_cell] - '0') & top_bottom_border;
    right = (map->cells[current_cell] - '0') & right_border;
    left = (map->cells[current_cell] - '0') & left_border;

    switch(border){
        case top_bottom_border:
            return (bool)top_bottom;
        case right_border:
            return (bool)right;
        case left_border:
            return (bool)left;
    }
  
    return 0;
}


//Testing if the map may really be constructed
int map_test(Map *map){
    int i_row = 1;
    int i_col;
    while(i_row <= map->rows){
        i_col = 1;
        while(i_col < map->cols){
            if(isborder(map, i_row, i_col, right_border) != isborder(map, i_row, i_col + 1, left_border)){
                return 1;
            }
            i_col++; 
        }
        i_row++;
    }

    i_row = 1;
    while(i_row < map->rows){
        i_col = 1;
        while(i_col <= map->cols){
            if((i_row + i_col) % 2 == 1){
                if(isborder(map, i_row, i_col, top_bottom_border) != isborder(map, i_row + 1, i_col, top_bottom_border)){
                    return 1;
                }
            }
            i_col++;
        }
        i_row++;
    }

    return 0; 
}

void map_free(Map *map){
    free(map->cells);
}

//Testing values of rows and cols if there are two numbers
int rows_cols_test(Map *map, char *rows_and_cols){
    char *end_ptr1 = NULL;
    char *end_ptr2 = NULL;
    map->rows = strtod(rows_and_cols, &end_ptr1);
    map->cols = strtod(end_ptr1, &end_ptr2);
    if(end_ptr2[0] != '\r' && end_ptr2[0] != '\n'){
        return 1;
    }
    return 0;
}

//Testing cells whether they do not contain invalid values
int cells_test(Map *map, FILE *f){
    int m = 0;
    char *tmp_string = (char *)malloc(sizeof(map->cells));
    int i = 0; 
    while(fgets(tmp_string, map->rows * map->cols, f) != NULL){
        int n = 0;
        while(tmp_string[n] != '\0'){
            if(tmp_string[n] >= '0' && tmp_string[n] <= '7'){
                if(tmp_string[n + 1] == ' ' || tmp_string[n + 1] == '\r' || tmp_string[n + 1] == '\n' || tmp_string[n + 1] == '\0'){
                    map->cells[m] = tmp_string[n];
                    m++;
                }
                else{
                    return 1;
                }
                n++;
            }
            else if(tmp_string[n] == ' ' || tmp_string[n] == '\r' || tmp_string[n] == '\n'){
                n++;
            }
            else{
                return 1;
            }
        }
        if((m % map->cols) != 0){
            return 1;
        }
        i++;
    }
    if(m != map->rows * map->cols){
        return 1;
    }
    free(tmp_string);
    return 0;
}

//Finding out the number of the rows and columns, allocation memory for map.cells
int map_init_and_fill(FILE *f, Map *map){
    char rows_and_cols[max_strlen];
    
    fgets(rows_and_cols, max_strlen, f);
    if(rows_cols_test(map, rows_and_cols) != 0){
        return 1;
    }
    
    map->cells = malloc(map->rows * map->cols * sizeof(unsigned char));
    if (map->cells == NULL){
        fprintf(stderr, "Memory was not allocated\n");
        return 1;
    }

    if(cells_test(map, f) != 0){
       return 1;
    }

    return map_test(map);
}

//Working with file, which contains map
int map_creation(char *filename, Map *map){
    FILE *f = fopen(filename, "r");
    int map_fill;
    if(f == NULL){
        fprintf(stderr, "File cannot be opened\n");
        return 1;
    }
    else{
        map_fill = map_init_and_fill(f, map);
    }
    fclose(f);
    return map_fill;
}

//Printing the result of testing map's validity
int call_map_test(int argc, char **argv, Map *map){
    if((map_creation(argv[argc - 1], map)) == 0){
        fprintf(stdout, "Valid\n");
    }
    else{
        fprintf(stdout, "Invalid\n");
    }
    return 0;
}

//Finding out the direction where to move from the start point
int start_border(Map *map, int row, int col, int leftright){
    if(leftright == right_hand){
        if((row + col) % 2 == 0){
            if(col == 1 && !isborder(map, row, col, left_border)){
                return right_border;
            }
            else if(col == map->cols && !isborder(map, row, col, right_border)){
                return top_bottom_border;
            }
            else if(row == 1 && !isborder(map, row, col, top_bottom_border)){
                return left_border;
            }
        }
        else{
            if(col == 1 && !isborder(map, row, col, left_border)){
                return top_bottom_border;
            }
            else if(col == map->cols && !isborder(map, row, col, right_border)){
                return left_border;
            }
            else if(row == map->rows && !isborder(map, row, col, top_bottom_border)){
                return right_border;
            }
        }
    }
    else if(leftright == left_hand){
        if((row + col) % 2 == 0){
            if(col == 1 && !isborder(map, row, col, left_border)){
                return top_bottom_border;
            }
            else if(col == map->cols && !isborder(map, row, col, right_border)){
                return left_border;
            }
            else if(row == 1 && !isborder(map, row, col, top_bottom_border)){
                return right_border;
            }
        }
        else{
            if(col == 1 && !isborder(map, row, col, left_border)){
                return right_border;
            }
            else if(col == map->cols && !isborder(map, row, col, right_border)){
                return top_bottom_border;
            }
            else if(row == map->rows && !isborder(map, row, col, top_bottom_border)){
                return left_border;
            }
        }
    }
    return invalid_start;
}

//Changing direction, because we do not want to move backwards
int turn_counterclockwise_left(int row, int col, int border){
    if((row + col) % 2 == 0)
        if((border == left_border) || (border == top_bottom_border)){
            border = right_border;
        }
        else{
            border = top_bottom_border;
        }
    else{
        if(border == left_border){
            border = top_bottom_border;
        }
        else{
            border = left_border;
        }
    }
    return border;
}

//Choosing which way to move if we have a border in front of us basing on left-hand rule
int turn_clockwise_left(int row, int col, int border){
    if((row + col) % 2 == 0)
        if(border == left_border){
            border = top_bottom_border;
        }
        else if(border == top_bottom_border){
            border = right_border;
        }
        else{
            border = left_border;
        }
    else{
        if(border == left_border){
            border = right_border;
        }
        else if(border == right_border){
            border = top_bottom_border;
        }
        else{
            border = left_border;
        }
    }
    return border;
}

//Changing direction, because we do not want to move backwards
int turn_clockwise_right(int row, int col, int border){
    if((row + col) % 2 == 0)
        if((border == right_border) || (border == top_bottom_border)){
            border = left_border;
        }
        else{
            border = top_bottom_border;
        }
    else{
        if(border == right_border){
            border = top_bottom_border;
        }
        else{
        border = right_border;
        }
    }
    return border;
}

//Choosing which way to move if we have a border on the way basing on right-hand rule
int turn_counterclockwise_right(int row, int col, int border){
    if((row + col) % 2 == 0)
        if(border == right_border){
            border = top_bottom_border;
        }
        else if(border == top_bottom_border){
            border = left_border;
        }
        else{
            border = right_border;
        }
    else{
        if(border == right_border){
            border = left_border;
        }
        else if(border == left_border){
            border = top_bottom_border;
        }
        else{
            border = right_border;
        }
    }
    return border;
}

//Moving through the maze using right-hand or left-hand rule and printing current location
int hand_rules(Map *map, int row, int col, int border, int hand_rule){
    while(row >= 1 && row <= map->rows && col >= 1 && col <= map->cols){
        while(isborder(map, row, col, border)){
            if(hand_rule == right_hand){
                border = turn_counterclockwise_right(row, col, border);
            }
            else{
                border = turn_clockwise_left(row, col, border);
            }
        }
        fprintf(stdout, "%d,%d\n", row, col);
        
        if(border == left_border){
            col--;
        }
        else if(border == right_border){
            col++;
        }
        else if((row + col) % 2 == 0 && border == top_bottom_border){
            row--;
        }
        else{
            row++;
        }
        
        if(hand_rule == right_hand){
            if((((row + col) % 2  == 0) && (border == right_border)) || ((((row + col) % 2  == 1) && border == left_border))){
            }
            else{
                border = turn_clockwise_right(row, col, border);
            }       
        }
        else{
            if((((row + col) % 2  == 0) && (border == left_border)) || ((((row + col) % 2  == 1) && border == right_border))){
            }
            else{
                border = turn_counterclockwise_left(row, col, border);
            }
        }
    }
    return 0;
}

//Printing how to use the program
void help_print(){
    fprintf(stdout, "You are using a program, which finds a way out of a maze.\n\n");
    fprintf(stdout, "To test a map, type \"./proj3 --test filename.txt\".\n");
    fprintf(stdout, "If the map in the file is valid, you will see the message \"Valid\", otherwise \"Invalid\".\n\n");
    fprintf(stdout, "To find a way out using right-hand rule (right hand is always on the wall),\n");
    fprintf(stdout, "type \"./proj3 --rpath R C filename.txt\",\n");
    fprintf(stdout, "where R is the number of the row and C is the number of the column of the start cell.\n\n");
    fprintf(stdout, "To find a way using left-hand rule (left hand is always on the wall),\n");
    fprintf(stdout, "type \"./proj3 --lpath R C filename.txt\",\n");
    fprintf(stdout, "where R is the number of the row and C is the number of the column of the start cell.\n\n");
    fprintf(stdout, "Hope, you will enjoy using this program.\n");
}

//Checking if start cell is entered as two numbers
int is_number(char *number){
    char *end_ptr = NULL;
    double value = strtod(number, &end_ptr);
    
    if(*end_ptr != '\0'){
      	return 0;
    }
    else{
        return value;
    }
}

//Checking validity of arguments
int arguments_check(int argc, char **argv){
    if(argc == 2){
        if(strcmp(argv[1], "--help") == 0){
            return 0;
        }
    }
    else if(strstr(argv[argc - 1], ".txt") != NULL){
        if(strcmp(strstr(argv[argc - 1], ".txt"), ".txt") == 0){
            if(argc == 3){
                if(strcmp(argv[1], "--test") == 0){
                    return 0;
                }
            }
            else if(argc == 5){
                if((strcmp(argv[1], "--rpath") == 0) || (strcmp(argv[1], "--lpath") == 0)){
                    int r = is_number(argv[2]);
                    int c = is_number(argv[3]);
                    if((r > 0) && (c > 0)){
                        return 0;
                    }  
                }
            }
        }
    }
    return 1;
}

int main(int argc, char **argv){
    if(arguments_check(argc, argv) == 1){
        fprintf(stderr, "Error! Wrong arguments\n");
        return 1;
    }
    
    Map map;
    if(strcmp((argv[1]), "--help") == 0){
        help_print();
    }
    else if(strcmp((argv[1]), "--test") == 0){
        call_map_test(argc, argv, &map);
        map_free(&map);
    }
    else if((strcmp((argv[1]), "--rpath") == 0) || (strcmp((argv[1]), "--lpath") == 0)){
        int start_row = is_number(argv[2]);
        int start_col = is_number(argv[3]);
        if((map_creation(argv[argc - 1], &map)) == 0){
            if ((start_row > map.rows) || (start_col > map.cols)){
                fprintf(stderr, "Invalid start cell\n");
                return 1;
            }
            int border;
            if(strcmp((argv[1]), "--rpath") == 0){
                border = start_border(&map, start_row, start_col, right_hand);
                hand_rules(&map, start_row, start_col, border, right_hand);
            }
            else{
                border = start_border(&map, start_row, start_col, left_hand);
                hand_rules(&map, start_row, start_col, border, left_hand);
            }
	        map_free(&map);
        }
        else{
            fprintf(stderr, "Invalid map. Launch program using a valid map\n");
        }
    }
    return 0;
}
