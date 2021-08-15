import numpy as np

class GuessingGame:
    def __init__(self, maxtries=10):
        self.target = np.random.randint(0,100)
        self.tries = 0
        self.max_tries=maxtries

    def play(self):
        for i in range(self.max_tries):
            guess = int(input())
            if guess == self.target:
                print('Succcess after '+ str(i+1)+'tries')
                return
            if guess > self.target:
                print('The target is smaller')
            else:
                print('The target is greater')

        print('Failure')



game1 = GuessingGame()
game1.play()