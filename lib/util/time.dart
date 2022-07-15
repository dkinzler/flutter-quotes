typedef TimeFunc = DateTime Function();

//we can override this for tests
//for a more general approach see the clock package
TimeFunc currentTime = () {
  return DateTime.now();
};