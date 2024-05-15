typedef TimeFunc = DateTime Function();

// we can override this for tests to make DateTime values predictable
// for a more general approach to achieve this see the clock package
TimeFunc currentTime = () {
  return DateTime.now();
};
