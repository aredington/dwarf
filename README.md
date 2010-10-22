# Dwarf Classifying

Dwarf provides a decision tree learning tool initially targeting
classification of Rails 3 ActiveRecord objects. Dwarf is largely
agnostic of types so long as they implement a few methods.

## Install

    gem install dwarf

This will install dwarf.

## Classifying

Dwarf targets the interactive Rails console for the time being, 
though there is nothing preventing it from being used in your code as
well. Suppose you have some records (record1, record2, ... , recordN)
that you know the classifications of. Instantiate a Classifier, inform
the instance of the classifications via the add_example method, and
then call learn!. The classifier will build a decision tree from your
examples as well as a classify method to classify arbitrary instances
you hand it. 

Teaching:

    classifier = Dwarf::Classifier.new()
    classifier.add_example(record1, :good)
    classifier.add_example(record2, :good)
    classifier.add_example(record3, :bad)
    .
    .
    .
    classifier.add_example(recordN, :bad)
    classifier.learn!

Classifying

    classifier.classify(record1) => :good
    classifier.classify(unseen_record) => :good

Dwarf will make a best guess attempt to classify records it has not
seen yet. If the features of a record are not sufficient to classify
it (e.g. two or more records have the same features, but different
classifications) Dwarf will always guess the classification it has
seen most often for that particular feature set.

## Contribute

Fork the dwarf project on github (http://github.com/aredington/dwarf),
document your changes, and then send a pull request.
