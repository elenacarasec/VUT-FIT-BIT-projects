#ifndef PROJ3_H
#define PROJ3_H

/**
 * @brief Structure, which keeps information about the labyrinth
 * @author Elena Carasec
* @date December 2019
*/
typedef struct {
    int rows;   /**< Number of rows in the labyrinth >*/
    int cols;   /**< Number of columns in the labyrinth >*/
    unsigned char *cells;   /**< Values of borders of each cell >*/
} Map;

/**
 * @brief Explains which number refers to each border
 * @author Elena Carasec
 * @date December 2019
 */
enum borders { BLEFT=0x1, BRIGHT=0x2, BTOP=0x4, BBOTTOM=0x4 };

/**
 * @param [in] map  The map of labyrinth
 * @return void
 * 
 * @pre     Structure map, which contains values
 * @post    Empty structure map
 * 
 * @author Elena Carasec
 * @date December 2019
 */
void free_map(Map *map);

/**
 * @param [in] filename     Name of the file, which contains values of
 *  numbers of rows, columns and cells borders
 * @param [in] map          Structure map, which is created to contain
 *  info about labyrinth's map  
 * @return  0, if map was filled in successfully, otherwise 1
 * 
 * @pre     Empty map
 * @post    Filled in map
 * 
 * @author Elena Carasec
 * @date December 2019
 */
int load_map(const char *filename, Map *map);

/**
 * @param [in] map  Structure map, which contains info about labyrinth's map 
 * @param [in] r    Number of the row of the cell, which it examines
 * @param [in] c    Number of the column of the cell, which it examines
 * @param [in] border   Value of border (see enum borders), which we want to find out
 * if this cell has it
 * @return  0 if there is no border, otherwise 1
 * 
 * @pre     Filled in map, valid r and c
 * 
 * @author Elena Carasec
 * @date December 2019
 */
bool isborder(Map *map, int r, int c, int border);

/**
 * @param [in] r    Number of the row of the cell, which it examines
 * @param [in] c    Number of the column of the cell, which it examines
 * @return  0 if the cell has no bottom border, otherwise 1
 * 
 * @pre     Filled in map, valid r and c
 * 
 * @author Elena Carasec
 * @date December 2019
 */
bool hasbottom(int r, int c);

/**
 * @param [in] map  Structure map, which contains info about labyrinth's map 
 * @param [in] r    Number of the row of the cell, 
 * from which it will start to find te way out
 * @param [in] c    Number of the column of the cell,
 * from which it will start to find te way out
 * @param [in] leftright    Expands to the value of "left" if the way out is looked for
 * according to the left-hand rule; expands to the value of "right" if the way out
 * is looked for according to the rigth-hand rule
 * 
 * @return  The value of the first border that should be examined
 * 
 * @pre     Filled in, valid map
 * 
 * @author Elena Carasec
 * @date December 2019
 */
int start_border(Map *map, int r, int c, int leftright);

/**
 * @param [in] map Structure map, which contains info about labyrinth's map
 * @return  Value that says if the map is valid. 1 refers to valid, 0 to invalid map
 * 
 * @pre     Filled in, untested map
 * @post    Filled in, tested map
 * 
 * @author Elena Carasec
 * @date December 2019
 */
int check_map(Map *map);

/**
 * @param [in] filename     Name of the file, which contains values of
 *  numbers of rows, columns and cells borders
 * @param [in] map          Structure map, which is created to contain
 *  info about labyrinth's map  
 * @return  0, if map was filled in successfully and is valid, otherwise 1
 * 
 * @pre     Empty untested map
 * @post    Filled in tested map
 * 
 * @author Elena Carasec
 * @date December 2019
 */
int load_and_check_map(const char *filename, Map *map);

/**
 * @param [in] map  Structure map, which contains info about labyrinth's map 
 * @param [in] r    Number of the row, from which it is going to start finding the way out
 * @param [in] c    Number of the column, from which it is going to start 
 * finding the way out
 * @return  0 if the cell is in the labyrinth, 1 if it is out of the labyrinth
 * 
 * @pre     Filled in map
 * 
 * @author Elena Carasec
 * @date December 2019
 */
bool is_out(Map *map, int r, int c);

/**
 * @param [in] map  Structure map, which contains info about labyrinth's map 
 * @param [in] r    Number of the row of the cell, that it goes through
 * @param [in] c    Number of the column of the cell, that it goes through
 * @param [in] leftright    Expands to the value of "left" if the way out is looked for
 * according to the left-hand rule; expands to the value of "right" if the way out
 * is looked for according to the rigth-hand rule
 * @return  void
 * 
 * @pre     Filled in, valid map
 * @post    Printed coordinates of cells that it went through
 * 
 * @author Elena Carasec
 * @date December 2019
 */
void print_path(Map *map, int r, int c, int leftright);

#endif