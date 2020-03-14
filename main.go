package main

import (
	"fmt"
	"io/ioutil"
	"strings"

	"github.com/cavaliercoder/go-rpm"
	"github.com/cavaliercoder/go-rpm/version"
)

type SpaceRepository struct {
	packages []Package
	name     string
}

type Package struct {
	files       []*rpm.PackageFile
	name        string
	latest      *rpm.PackageFile
	latest_name string
}

// create a slice of Package from a slice of strings representing paths, the Package
// struct will give the latest package as well as a slice with pointers towards all
// other rpm.PackageFile's matching the Package.name
func getPackages(paths []string) []Package {
	var packages []Package
	// list files in directory
	for _, path := range paths {
		dir, err := ioutil.ReadDir(path)
		if err != nil {
			panic(err)
		}
		// add rpm files to packages slice with
		for _, f := range dir {
			counter := 0
			if strings.HasSuffix(f.Name(), ".rpm") {
				// read package file
				pkg, err := rpm.OpenPackageFile(path + "/" + f.Name())
				if err != nil {
					panic(err)
				}
				// compare versions and see if package is in list
				for index, value := range packages {
					if value.name == pkg.Name() {
						if 1 == version.Compare(pkg, value.latest) {
							packages[index].latest = pkg
							packages[index].latest_name = f.Name()
						}
						packages[index].files = append(value.files, pkg)
						counter = 1
					}
				}
				// package not in slice, lets add it
				if counter == 0 {
					var p Package
					p.files = append(p.files, pkg)
					p.name = pkg.Name()
					p.latest = pkg
					p.latest_name = f.Name()
					packages = append(packages, p)
				}
			}
		}
	}
	return packages
}

func main() {
	var dirs []string
	dirs = append(dirs, "/tmp/rpms")
	sr := SpaceRepository{packages: getPackages(dirs), name: "testing-rpms"}
	fmt.Printf("%v\n", sr)
}
