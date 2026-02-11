import SwiftUI
import CoreData


struct FavoritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let userId: String

    @FetchRequest private var favorites: FetchedResults<FavoriteListing>

    init(userId: String) {
        self.userId = userId
        _favorites = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteListing.savedAt, ascending: false)],
            predicate: NSPredicate(format: "userId == %@", userId),
            animation: .default
        )
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(favorites) { fav in
                    NavigationLink {
                        ListingDetailsView(listing: Listing(from: fav))
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fav.title ?? "Untitled")
                                .font(.headline)

                            Text("$\(fav.price, specifier: "%.0f") • \(fav.address ?? "")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteFavorites)
            }
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }

       
                // ToolbarItem(placement: .navigationBarTrailing) {
                //     Button(action: addSampleFavorite) {
                //         Label("Add Favorite", systemImage: "plus")
                //     }
                // }
            }
        }
    }

    private func deleteFavorites(offsets: IndexSet) {
        withAnimation {
            offsets.map { favorites[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print("Delete favorite error:", error)
            }
        }
    }
}
