// Copyright (c) 2015, Andrew Mezoni
// All rights reserved.
// Subject to BSD 3-clause license. See file LICENSE_MEZONI.

import "dart:async";

import "package:sync/semaphore.dart";
import "package:test/test.dart";

void main() {
  group("Semaphore", () {
    test("semaphore synchronisation", () async {
      var res1 = [];
      var res2 = [];
      Future action(List res, int milliseconds) {
        expect(res.length, 0, reason: "Not exlusive start");
        res.length++;
        var completer = new Completer();
        new Timer(new Duration(milliseconds: milliseconds), () {
          expect(res.length, 1, reason: "Not exlusive end");
          res.length--;
          completer.complete();
        });

        return completer.future;
      }

      var s1 = new Semaphore(1);
      var s2 = new Semaphore(1);
      var list = [];
      for (var i = 0; i < 3; i++) {
        Future f(Semaphore s, List l) async {
          try {
            await s.acquire();
            await action(l, 100);
          } finally {
            s.release();
          }
        }

        list.add(new Future(() => f(s1, res1)));
        list.add(new Future(() => f(s2, res2)));
      }

      // Run concurrently
      await Future.wait(list);
    });

    test("semaphore max count", () async {
      var list1 = [];
      var maxCount = 3;
      Future action(List list, int milliseconds) {
        expect(list.length <= maxCount, true, reason: "Not exlusive start");
        list.length++;
        var completer = new Completer();
        new Timer(new Duration(milliseconds: milliseconds), () {
          expect(list.length <= maxCount, true, reason: "Not exlusive end");
          list.length--;
          completer.complete();
        });

        return completer.future;
      }

      var s1 = new Semaphore(3);
      var list = [];
      for (var i = 0; i < maxCount * 2; i++) {
        Future f(Semaphore s, List l) async {
          try {
            await s.acquire();
            await action(l, 100);
          } finally {
            s.release();
          }
        }

        list.add(new Future(() => f(s1, list1)));
      }

      // Run concurrently
      await Future.wait(list);
    });
  });
}
