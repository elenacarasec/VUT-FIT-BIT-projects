/*
**      Title:              IZP Project2
**      Start date:         2019-11-17
**      Last modification:  2019-11-26
**      Created by:         Elena Carasec (xcaras00)
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define I_0 1e-12
#define U_t 0.0258563

//Calculating the difference between current values on diode and on resistor. 
double calc_current_difference(double U_0, double U_p, double r){
    //Shockley diode equation.
    double I_p = I_0 * (expl(U_p / U_t) - 1);

    //Ohm's law.
    double I_r = (U_0 - U_p) / r;

    //Kirchhoff's current law.
    double cur_diff = I_p - I_r; 

    return cur_diff;
}

//Using bisection method for calculation voltage on diode.
double diode(double U_0, double r, double eps){
    double x1 = 0;
    double x2 = U_0;
    double dx = 0;
    double x_mid = (x2 - x1)/ 2;
    
    while((x2 - x1) > eps){
        dx = (x2 - x1) / 2;
        x_mid = x1 + dx;
	if(x_mid == x2){
	    return x_mid;
	}

	if((calc_current_difference(U_0, x2, r) * calc_current_difference(U_0, x_mid, r)) < 0){
            x1 = x_mid;
        }
        else{
            x2 = x_mid;
        }
    }
    return x_mid;
}

//Testing if it is possible to work with entered values.
int arg_test(char *arg){
    char *end_ptr = NULL;
    double value = strtod(arg, &end_ptr);
    if(*end_ptr != '\0'){
        fprintf(stderr, "error: invalid arguments\n");
	return 1;
    }	
    if(value < 0){
        fprintf(stderr, "error: invalid arguments\n");
        return 1;
    }
    return 0;
}



int main(int argc, char **argv){
    if(argc == 4){
        int i = 1;
        while (i < argc){
            int test = arg_test(argv[i]);
            if (test != 0){
                    return 1;
                }
            i++;
        }

        double U_0 = strtod(argv[1], NULL);
        double r = strtod(argv[2], NULL);
	if (r == 0){
	    fprintf(stderr, "error: invalid arguments\n");
	    return 1;
	}
        double eps = strtod(argv[3], NULL);

        double U_p = diode(U_0, r, eps); 
	double I_p = I_0 * (expl(U_p / U_t) - 1);

        fprintf(stdout, "Up=%g V\n", U_p);
        fprintf(stdout, "Ip=%g A\n", I_p);
    }
    else{
        fprintf(stderr, "Please, enter 3 arguments\n");
        return 1;
    }

    return 0;
}
