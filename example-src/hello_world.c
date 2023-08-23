#include <stdio.h>
#include <unistd.h>
#include "anvil__hello_world.h"

int main(void) {
  printf("Hello, World!\n");
  printf("Built using amboso API v%s\n",get_ANVIL__API__LEVEL__());
  printf("amboso v%s\n",get_ANVIL__VERSION__());
  /*
  printf("New:%s\n",get_ANVIL__VERSION__DESC__());
  printf("Date:%s\n",get_ANVIL__VERSION__DATE__());
  printf("Author:%s\n",get_ANVIL__VERSION__AUTHOR__());
  */
  return 0;
}
